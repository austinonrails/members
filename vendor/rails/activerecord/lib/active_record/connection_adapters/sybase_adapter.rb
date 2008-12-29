# sybase_adaptor.rb
# Author: John Sheets <dev@metacasa.net>
# Date:   01 Mar 2006
#
# Based on code from Will Sobel (http://dev.rubyonrails.org/ticket/2030)
#
# 17 Mar 2006: Added support for migrations; fixed issues with :boolean columns.
#

require 'active_record/connection_adapters/abstract_adapter'

begin
require 'sybsql'

module ActiveRecord
  class Base
    # Establishes a connection to the database that's used by all Active Record objects
    def self.sybase_connection(config) # :nodoc:
      config = config.symbolize_keys

      username = config[:username] ? config[:username].to_s : 'sa'
      password = config[:password] ? config[:password].to_s : ''

      if config.has_key?(:host)
        host = config[:host]
      else
        raise ArgumentError, "No database server name specified. Missing argument: host."
      end

      if config.has_key?(:database)
        database = config[:database]
      else
        raise ArgumentError, "No database specified. Missing argument: database."
      end

      ConnectionAdapters::SybaseAdapter.new(
        SybSQL.new({'S' => host, 'U' => username, 'P' => password},
          ConnectionAdapters::SybaseAdapterContext), database, logger)
    end
  end # class Base

  module ConnectionAdapters

    # ActiveRecord connection adapter for Sybase Open Client bindings
    # (see http://raa.ruby-lang.org/project/sybase-ctlib).
    #
    # Options:
    #
    # * <tt>:host</tt> -- The name of the database server. No default, must be provided.
    # * <tt>:database</tt> -- The name of the database. No default, must be provided.
    # * <tt>:username</tt>  -- Defaults to sa.
    # * <tt>:password</tt>  -- Defaults to empty string.
    #
    # Usage Notes:
    #
    # * The sybase-ctlib bindings do not support the DATE SQL column type; use DATETIME instead.
    # * Table and column names are limited to 30 chars in Sybase 12.5
    # * :binary columns not yet supported
    # * :boolean columns use the BIT SQL type, which does not allow nulls or 
    #   indexes.  If a DEFAULT is not specified for ALTER TABLE commands, the
    #   column will be declared with DEFAULT 0 (false).
    #
    # Migrations:
    #
    # The Sybase adapter supports migrations, but for ALTER TABLE commands to
    # work, the database must have the database option 'select into' set to
    # 'true' with sp_dboption (see below).  The sp_helpdb command lists the current
    # options for all databases.
    #
    #   1> use mydb
    #   2> go
    #   1> master..sp_dboption mydb, "select into", true
    #   2> go
    #   1> checkpoint
    #   2> go
    class SybaseAdapter < AbstractAdapter # :nodoc:
      class ColumnWithIdentity < Column
        attr_reader :identity, :primary

        def initialize(name, default, sql_type = nil, nullable = nil, identity = nil, primary = nil)
          super(name, default, sql_type, nullable)
          @default, @identity, @primary = type_cast(default), identity, primary
        end

        def simplified_type(field_type)
          case field_type
            when /int|bigint|smallint|tinyint/i                        then :integer
            when /float|double|decimal|money|numeric|real|smallmoney/i then :float
            when /text|ntext/i                                         then :text
            when /binary|image|varbinary/i                             then :binary
            when /char|nchar|nvarchar|string|varchar/i                 then :string
            when /bit/i                                                then :boolean
            when /datetime|smalldatetime/i                             then :datetime
            else                                                       super
          end
        end

        def self.string_to_binary(value)
          "0x#{value.unpack("H*")[0]}"
        end

        def self.binary_to_string(value)
          # FIXME: sybase-ctlib uses separate sql method for binary columns.
          value
        end
      end # class ColumnWithIdentity

      # Sybase adapter
      def initialize(connection, database, logger = nil)
        super(connection, logger)
        context = connection.context
        context.init(logger)
        @limit = @offset = 0
        unless connection.sql_norow("USE #{database}")
          raise "Cannot USE #{database}"
        end
      end

      def native_database_types
        {
          :primary_key => "numeric(9,0) IDENTITY PRIMARY KEY",
          :string      => { :name => "varchar", :limit => 255 },
          :text        => { :name => "text" },
          :integer     => { :name => "int" },
          :float       => { :name => "float", :limit => 8 },
          :datetime    => { :name => "datetime" },
          :timestamp   => { :name => "timestamp" },
          :time        => { :name => "time" },
          :date        => { :name => "datetime" },
          :binary      => { :name => "image"},
          :boolean     => { :name => "bit" }
        }
      end

      def adapter_name
        'Sybase'
      end

      def active?
        !(@connection.connection.nil? || @connection.connection_dead?)
      end

      def disconnect!
        @connection.close rescue nil
      end

      def reconnect!
        raise "Sybase Connection Adapter does not yet support reconnect!"
        # disconnect!
        # connect! # Not yet implemented
      end

      def table_alias_length
        30
      end

      # Check for a limit statement and parse out the limit and
      # offset if specified. Remove the limit from the sql statement
      # and call select.
      def select_all(sql, name = nil)
        select(sql, name)
      end

      # Remove limit clause from statement. This will almost always
      # contain LIMIT 1 from the caller. set the rowcount to 1 before
      # calling select.
      def select_one(sql, name = nil)
        result = select(sql, name)
        result.nil? ? nil : result.first
      end

      def columns(table_name, name = nil)
        table_structure(table_name).inject([]) do |columns, column|
          name, default, type, nullable, identity, primary = column
          columns << ColumnWithIdentity.new(name, default, type, nullable, identity, primary)
          columns
        end
      end

      def insert(sql, name = nil, pk = nil, id_value = nil, sequence_name = nil)
        begin
          table_name = get_table_name(sql)
          col = get_identity_column(table_name)
          ii_enabled = false

          if col != nil
            if query_contains_identity_column(sql, col)
              begin
                execute enable_identity_insert(table_name, true)
                ii_enabled = true
              rescue Exception => e
                raise ActiveRecordError, "IDENTITY_INSERT could not be turned ON"
              end
            end
          end

          log(sql, name) do
            execute(sql, name)
            ident = select_one("SELECT @@IDENTITY AS last_id")["last_id"]
            id_value || ident
          end
        ensure
          if ii_enabled
            begin
              execute enable_identity_insert(table_name, false)
            rescue Exception => e
              raise ActiveRecordError, "IDENTITY_INSERT could not be turned OFF"
            end
          end
        end
      end

      def execute(sql, name = nil)
        log(sql, name) do
          @connection.context.reset
          @connection.set_rowcount(@limit || 0)
          @limit = @offset = nil
          @connection.sql_norow(sql)
          if @connection.cmd_fail? or @connection.context.failed?
            raise "SQL Command Failed for #{name}: #{sql}\nMessage: #{@connection.context.message}"
          end
        end
        # Return rows affected
        @connection.results[0].row_count
      end

      alias_method :update, :execute
      alias_method :delete, :execute

      def begin_db_transaction()    execute "BEGIN TRAN" end
      def commit_db_transaction()   execute "COMMIT TRAN" end
      def rollback_db_transaction() execute "ROLLBACK TRAN" end

      def tables(name = nil)
        tables = []
        select("select name from sysobjects where type='U'", name).each do |row|
          tables << row['name']
        end
        tables
      end

      def indexes(table_name, name = nil)
        indexes = []
        select("exec sp_helpindex #{table_name}", name).each do |index|
          unique = index["index_description"] =~ /unique/
          primary = index["index_description"] =~ /^clustered/
          if !primary
            cols = index["index_keys"].split(", ").each { |col| col.strip! }
            indexes << IndexDefinition.new(table_name, index["index_name"], unique, cols)
          end
        end
        indexes
      end

      def quoted_true
        "1"
      end

      def quoted_false
        "0"
      end

      def quote(value, column = nil)
        case value
          when String                
            if column && column.type == :binary && column.class.respond_to?(:string_to_binary)
              "#{quote_string(column.class.string_to_binary(value))}"
            elsif value =~ /^[+-]?[0-9]+$/o
              value
            else
              "'#{quote_string(value)}'"
            end
          when NilClass              then (column && column.type == :boolean) ? '0' : "NULL"
          when TrueClass             then '1'
          when FalseClass            then '0'
          when Float, Fixnum, Bignum then value.to_s
          when Date                  then "'#{value.to_s}'" 
          when Time, DateTime        then "'#{value.strftime("%Y-%m-%d %H:%M:%S")}'"
          else                            "'#{quote_string(value.to_yaml)}'"
        end
      end

      def quote_column(type, value)
        case type
          when :boolean
            case value
              when String then value =~ /^[ty]/o ? 1 : 0
              when true   then 1
              when false  then 0
              else             value.to_i
            end
          when :integer then value.to_i
          when :float   then value.to_f
          when :text, :string, :enum
            case value
              when String, Symbol, Fixnum, Float, Bignum, TrueClass, FalseClass 
                "'#{quote_string(value.to_s)}'"
              else
                "'#{quote_string(value.to_yaml)}'"
            end
          when :date, :datetime, :time
            case value
              when Time, DateTime then "'#{value.strftime("%Y-%m-%d %H:%M:%S")}'"
              when Date           then "'#{value.to_s}'"
              else                     "'#{quote_string(value)}'"
            end
          else "'#{quote_string(value.to_yaml)}'"
        end
      end

      def quote_string(s)
        s.gsub(/'/, "''") # ' (for ruby-mode)
      end

      def quote_column_name(name)
        "[#{name}]"
      end

      def add_limit_offset!(sql, options) # :nodoc:
        @limit = options[:limit]
        @offset = options[:offset]
        if !normal_select?
          # Use temp table to hack offset with Sybase
          sql.sub!(/ FROM /i, ' INTO #artemp FROM ')
        elsif zero_limit?
          # "SET ROWCOUNT 0" turns off limits, so we have
          # to use a cheap trick.
          if sql =~ /WHERE/i
            sql.sub!(/WHERE/i, 'WHERE 1 = 2 AND ')
          elsif sql =~ /ORDER\s+BY/i
            sql.sub!(/ORDER\s+BY/i, 'WHERE 1 = 2 ORDER BY')
          else
            sql << 'WHERE 1 = 2'
          end
        end
      end

      def supports_migrations? #:nodoc:
        true
      end

      def rename_table(name, new_name)
        execute "EXEC sp_rename '#{name}', '#{new_name}'"
      end

      def rename_column(table, column, new_column_name)
        execute "EXEC sp_rename '#{table}.#{column}', '#{new_column_name}'"
      end

      def change_column(table_name, column_name, type, options = {}) #:nodoc:
        sql_commands = ["ALTER TABLE #{table_name} MODIFY #{column_name} #{type_to_sql(type, options[:limit])}"]
        if options[:default]
          remove_default_constraint(table_name, column_name)
          sql_commands << "ALTER TABLE #{table_name} ADD CONSTRAINT DF_#{table_name}_#{column_name} DEFAULT #{options[:default]} FOR #{column_name}"
        end
        sql_commands.each { |c| execute(c) }
      end

      def remove_column(table_name, column_name)
        remove_default_constraint(table_name, column_name)
        execute "ALTER TABLE #{table_name} DROP #{column_name}"
      end

      def remove_default_constraint(table_name, column_name)
        defaults = select "select def.name from sysobjects def, syscolumns col, sysobjects tab where col.cdefault = def.id and col.name = '#{column_name}' and tab.name = '#{table_name}' and col.id = tab.id"
        defaults.each {|constraint|
          execute "ALTER TABLE #{table_name} DROP CONSTRAINT #{constraint["name"]}"
        }
      end

      def remove_index(table_name, options = {})
        execute "DROP INDEX #{table_name}.#{index_name(table_name, options)}"
      end

      def add_column_options!(sql, options) #:nodoc:
        sql << " DEFAULT #{quote(options[:default], options[:column])}" unless options[:default].nil?

        if check_null_for_column?(options[:column], sql)
          sql << (options[:null] == false ? " NOT NULL" : " NULL")
        end
        sql
      end

    private
      def check_null_for_column?(col, sql)
        # Sybase columns are NOT NULL by default, so explicitly set NULL
        # if :null option is omitted.  Disallow NULLs for boolean.
        type = col.nil? ? "" : col[:type]

        # Ignore :null if a primary key
        return false if type =~ /PRIMARY KEY/i

        # Ignore :null if a :boolean or BIT column
        if (sql =~ /\s+bit(\s+DEFAULT)?/i) || type == :boolean
          # If no default clause found on a boolean column, add one.
          sql << " DEFAULT 0" if $1.nil?
          return false
        end
        true
      end

      # Return the last value of the identity global value.
      def last_insert_id
        @connection.sql("SELECT @@IDENTITY")
        unless @connection.cmd_fail?
          id = @connection.top_row_result.rows.first.first
          if id
            id = id.to_i
            id = nil if id == 0
          end
        else
          id = nil
        end
        id
      end

      def affected_rows(name = nil)
        @connection.sql("SELECT @@ROWCOUNT")
        unless @connection.cmd_fail?
          count = @connection.top_row_result.rows.first.first
          count = count.to_i if count
        else
          0
        end
      end

      def normal_select?
        # If limit is not set at all, we can ignore offset;
        # If limit *is* set but offset is zero, use normal select
        # with simple SET ROWCOUNT.  Thus, only use the temp table
        # if limit is set and offset > 0.
        has_limit = !@limit.nil?
        has_offset = !@offset.nil? && @offset > 0
        !has_limit || !has_offset
      end

      def zero_limit?
        !@limit.nil? && @limit == 0
      end

      # Select limit number of rows starting at optional offset.
      def select(sql, name = nil)
        @connection.context.reset
        log(sql, name) do
          if normal_select?
            # If limit is not explicitly set, return all results.
            @logger.debug "Setting row count to (#{@limit || 'off'})" if @logger

            # Run a normal select
            @connection.set_rowcount(@limit || 0)
            @connection.sql(sql)
          else
            # Select into a temp table and prune results
            @logger.debug "Selecting #{@limit + (@offset || 0)} or fewer rows into #artemp" if @logger
            @connection.set_rowcount(@limit + (@offset || 0))
            @connection.sql_norow(sql)  # Select into temp table
            @logger.debug "Deleting #{@offset || 0} or fewer rows from #artemp" if @logger
            @connection.set_rowcount(@offset || 0)
            @connection.sql_norow("delete from #artemp") # Delete leading rows
            @connection.set_rowcount(0)
            @connection.sql("select * from #artemp") # Return the rest
          end
        end

        rows = []
        if @connection.context.failed? or @connection.cmd_fail?
          raise StatementInvalid, "SQL Command Failed for #{name}: #{sql}\nMessage: #{@connection.context.message}"
        else
          results = @connection.top_row_result
          if results && results.rows.length > 0
            fields = fixup_column_names(results.columns)
            results.rows.each do |row|
              hashed_row = {}
              row.zip(fields) { |cell, column| hashed_row[column] = cell }
              rows << hashed_row
            end
          end
        end
        @connection.sql_norow("drop table #artemp") if !normal_select?
        @limit = @offset = nil
        return rows
      end

      def enable_identity_insert(table_name, enable = true)
        if has_identity_column(table_name)
          "SET IDENTITY_INSERT #{table_name} #{enable ? 'ON' : 'OFF'}"
        end
      end

      def get_table_name(sql)
        if sql =~ /^\s*insert\s+into\s+([^\(\s]+)\s*|^\s*update\s+([^\(\s]+)\s*/i
          $1
        elsif sql =~ /from\s+([^\(\s]+)\s*/i
          $1
        else
          nil
        end
      end

      def has_identity_column(table_name)
        !get_identity_column(table_name).nil?
      end

      def get_identity_column(table_name)
        @table_columns = {} unless @table_columns
        @table_columns[table_name] = columns(table_name) if @table_columns[table_name] == nil
        @table_columns[table_name].each do |col|
          return col.name if col.identity
        end

        return nil
      end

      def query_contains_identity_column(sql, col)
        sql =~ /\[#{col}\]/
      end

      # Remove trailing _ from names.
      def fixup_column_names(columns)
        columns.map { |column| column.sub(/_$/, '') }
      end

      def table_structure(table_name)
        sql = <<SQLTEXT
SELECT col.name AS name, type.name AS type, col.prec, col.scale, col.length,
  col.status, obj.sysstat2, def.text
 FROM sysobjects obj, syscolumns col, systypes type, syscomments def
 WHERE obj.id = col.id AND col.usertype = type.usertype AND col.cdefault *= def.id
  AND obj.type = 'U' AND obj.name = '#{table_name}' ORDER BY col.colid
SQLTEXT
        log(sql, "Get Column Info ") do
          @connection.set_rowcount(0)
          @connection.sql(sql)
        end
        if @connection.context.failed?
          raise "SQL Command for table_structure for #{table_name} failed\nMessage: #{@connection.context.message}"
        elsif !@connection.cmd_fail?
          columns = []
          results = @connection.top_row_result
          results.rows.each do |row|
            name, type, prec, scale, length, status, sysstat2, default = row
            type = normalize_type(type, prec, scale, length)
            default_value = nil
            name.sub!(/_$/o, '')
            if default =~ /DEFAULT\s+(.+)/o
              default_value = $1.strip
              default_value = default_value[1...-1] if default_value =~ /^['"]/o
            end
            nullable = (status & 8) == 8
            identity = status >= 128
            primary = (sysstat2 & 8) == 8

            columns << [name, default_value, type, nullable, identity, primary]
          end
          columns
        else
          nil
        end
      end

      def normalize_type(field_type, prec, scale, length)
        if field_type =~ /numeric/i and (scale.nil? or scale == 0)
          type = 'int'
        elsif field_type =~ /money/i
          type = 'numeric'
        else
          type = field_type
        end
        size = ''
        if prec
          size = "(#{prec})"
        elsif length
          size = "(#{length})"
        end
        return type + size
      end

      def default_value(value)
      end
    end # class SybaseAdapter

    class SybaseAdapterContext < SybSQLContext
      DEADLOCK = 1205
      attr_reader :message

      def init(logger = nil)
        @deadlocked = false
        @failed = false
        @logger = logger
        @message = nil
      end

      def srvmsgCB(con, msg)
        # Do not log change of context messages.
        if msg['severity'] == 10 or msg['severity'] == 0
          return true
        end

        if msg['msgnumber'] == DEADLOCK
          @deadlocked = true
        else
          @logger.info "SQL Command failed!" if @logger
          @failed = true
        end

        if @logger
          @logger.error "** SybSQLContext Server Message: **"
          @logger.error "  Message number #{msg['msgnumber']} Severity #{msg['severity']} State #{msg['state']} Line #{msg['line']}"
          @logger.error "  Server #{msg['srvname']}"
          @logger.error "  Procedure #{msg['proc']}"
          @logger.error "  Message String:  #{msg['text']}"
        end

        @message = msg['text']

        true
      end

      def deadlocked?
        @deadlocked
      end

      def failed?
        @failed
      end

      def reset
        @deadlocked = false
        @failed = false
        @message = nil
      end

      def cltmsgCB(con, msg)
        return true unless ( msg.kind_of?(Hash) )
        unless ( msg[ "severity" ] ) then
          return true
        end

        if @logger
          @logger.error "** SybSQLContext Client-Message: **"
          @logger.error "  Message number: LAYER=#{msg[ 'layer' ]} ORIGIN=#{msg[ 'origin' ]} SEVERITY=#{msg[ 'severity' ]} NUMBER=#{msg[ 'number' ]}"
          @logger.error "  Message String: #{msg['msgstring']}"
          @logger.error "  OS Error: #{msg['osstring']}"

          @message = msg['msgstring']
        end

        @failed = true

        # Not retry , CS_CV_RETRY_FAIL( probability TimeOut ) 
        if( msg[ 'severity' ] == "RETRY_FAIL" ) then
          @timeout_p = true
          return false
        end

        return true
      end
    end # class SybaseAdapterContext

  end # module ConnectionAdapters
end # module ActiveRecord


# Allow identity inserts for fixtures.
require "active_record/fixtures"
class Fixtures
  alias :original_insert_fixtures :insert_fixtures

  def insert_fixtures
    values.each do |fixture|
      allow_identity_inserts table_name, true
      @connection.execute "INSERT INTO #{@table_name} (#{fixture.key_list}) VALUES (#{fixture.value_list})", 'Fixture Insert'
      allow_identity_inserts table_name, false
    end
  end

  def allow_identity_inserts(table_name, enable)
      @connection.execute "SET IDENTITY_INSERT #{table_name} #{enable ? 'ON' : 'OFF'}" rescue nil
  end
end

rescue LoadError => cannot_require_sybase
  # Couldn't load sybase adapter
end