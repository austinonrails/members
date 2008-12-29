require 'active_record/migration'
require 'benchmark'

module ActiveRecord
  class Migration
    class <<self
      def send(message, *args, &block)
        case message
        when :up then announce "migrating"
        when :down then announce "reverting"
        end
        
        result = nil
        time = Benchmark.measure { result = super }

        case message
        when :up then announce "migrated (%.4fs)" % time.real; puts
        when :down then announce "reverted (%.4fs)" % time.real; puts
        end
        
        result
      end

      private
      
        def announce(message)
          text = "#{name}: #{message}"
          puts "== %s %s" % [ text, text.length < 75 ? "=" * (75 - text.length) : "" ]
        end

        def say(message, subitem=false)
          puts "#{subitem ? "   ->" : "--"} #{message}"
        end

        def say_with_time(message)
          say(message)
          result = nil
          time = Benchmark.measure { result = yield }
          say "%.4fs" % time.real, :subitem
          result
        end

        alias :migration_method_missing :method_missing
        def method_missing(method, *arguments, &block)
          say_with_time "#{method}(#{arguments.map { |a| a.inspect }.join(", ")})" do
            migration_method_missing(method, *arguments, &block)
          end
        end
    end
  end
end