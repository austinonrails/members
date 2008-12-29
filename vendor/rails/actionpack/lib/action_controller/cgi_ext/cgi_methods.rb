require 'cgi'
require 'action_controller/vendor/xml_simple'
require 'action_controller/vendor/xml_node'

# Static methods for parsing the query and request parameters that can be used in
# a CGI extension class or testing in isolation.
class CGIMethods #:nodoc:
  public
    # Returns a hash with the pairs from the query string. The implicit hash construction that is done in
    # parse_request_params is not done here.
    def CGIMethods.parse_query_parameters(query_string)
      parsed_params = {}
  
      query_string.split(/[&;]/).each { |p| 
        # Ignore repeated delimiters.
        next if p.empty?

        k, v = p.split('=',2)
        v = nil if (v && v.empty?)

        k = CGI.unescape(k) if k
        v = CGI.unescape(v) if v

        unless k.include?(?[)
          parsed_params[k] = v
        else
          keys = split_key(k)
          last_key = keys.pop
          last_key = keys.pop if (use_array = last_key.empty?)
          parent = keys.inject(parsed_params) {|h, k| h[k] ||= {}}
          
          if use_array then (parent[last_key] ||= []) << v
          else parent[last_key] = v
          end
        end
      }
  
      parsed_params
    end

    # Returns the request (POST/GET) parameters in a parsed form where pairs such as "customer[address][street]" / 
    # "Somewhere cool!" are translated into a full hash hierarchy, like
    # { "customer" => { "address" => { "street" => "Somewhere cool!" } } }
    def CGIMethods.parse_request_parameters(params)
      parsed_params = {}

      for key, value in params
        value = [value] if key =~ /.*\[\]$/
        unless key.include?('[')
          # much faster to test for the most common case first (GET)
          # and avoid the call to build_deep_hash
          parsed_params[key] = get_typed_value(value[0])
        else
          build_deep_hash(get_typed_value(value[0]), parsed_params, get_levels(key))
        end
      end
    
      parsed_params
    end

    def self.parse_formatted_request_parameters(mime_type, raw_post_data)
      params = case strategy = ActionController::Base.param_parsers[mime_type]
        when Proc
          strategy.call(raw_post_data)
        when :xml_simple
          raw_post_data.blank? ? nil :
            typecast_xml_value(XmlSimple.xml_in(raw_post_data,
              'forcearray'   => false,
              'forcecontent' => true,
              'keeproot'     => true,
              'contentkey'   => '__content__'))
        when :yaml
          YAML.load(raw_post_data)
        when :xml_node
          node = XmlNode.from_xml(raw_post_data)
          { node.node_name => node }
      end
      
      dasherize_keys(params || {})
    rescue Object => e
      { "exception" => "#{e.message} (#{e.class})", "backtrace" => e.backtrace, 
        "raw_post_data" => raw_post_data, "format" => mime_type }
    end

    def self.typecast_xml_value(value)
      case value
      when Hash
        if value.has_key?("__content__")
          content = translate_xml_entities(value["__content__"])
          case value["type"]
          when "integer"  then content.to_i
          when "boolean"  then content == "true"
          when "datetime" then Time.parse(content)
          when "date"     then Date.parse(content)
          else                 content
          end
        else
          value.empty? ? nil : value.inject({}) do |h,(k,v)|
            h[k] = typecast_xml_value(v)
            h
          end
        end
      when Array
        value.map! { |i| typecast_xml_value(i) }
        case value.length
        when 0 then nil
        when 1 then value.first
        else value
        end
      else
        raise "can't typecast #{value.inspect}"
      end
    end

  private

    def self.translate_xml_entities(value)
      value.gsub(/&lt;/,   "<").
            gsub(/&gt;/,   ">").
            gsub(/&quot;/, '"').
            gsub(/&apos;/, "'").
            gsub(/&amp;/,  "&")
    end

    def self.dasherize_keys(params)
      case params.class.to_s
      when "Hash"
        params.inject({}) do |h,(k,v)|
          h[k.to_s.tr("-", "_")] = dasherize_keys(v)
          h
        end
      when "Array"
        params.map { |v| dasherize_keys(v) }
      else
        params
      end
    end

    # Splits the given key into several pieces. Example keys are 'name', 'person[name]',
    # 'person[name][first]', and 'people[]'. In each instance, an Array instance is returned.
    # 'person[name][first]' produces ['person', 'name', 'first']; 'people[]' produces ['people', '']
    def CGIMethods.split_key(key)
      if /^([^\[]+)((?:\[[^\]]*\])+)$/ =~ key
        keys = [$1]
        
        keys.concat($2[1..-2].split(']['))
        keys << '' if key[-2..-1] == '[]' # Have to add it since split will drop empty strings
        
        keys
      else
        [key]
      end
    end
    
    def CGIMethods.get_typed_value(value)
      # test most frequent case first
      if value.is_a?(String)
        value
      elsif value.respond_to?(:content_type) && ! value.content_type.blank?
        # Uploaded file
        unless value.respond_to?(:full_original_filename)
          class << value
            alias_method :full_original_filename, :original_filename

            # Take the basename of the upload's original filename.
            # This handles the full Windows paths given by Internet Explorer
            # (and perhaps other broken user agents) without affecting
            # those which give the lone filename.
            # The Windows regexp is adapted from Perl's File::Basename.
            def original_filename
              if md = /^(?:.*[:\\\/])?(.*)/m.match(full_original_filename)
                md.captures.first
              else
                File.basename full_original_filename
              end
            end
          end
        end

        # Return the same value after overriding original_filename.
        value

      elsif value.respond_to?(:read)
        # Value as part of a multipart request
        value.read
      elsif value.class == Array
        value.collect { |v| CGIMethods.get_typed_value(v) }
      else
        # other value (neither string nor a multipart request)
        value.to_s
      end
    end
  
    PARAMS_HASH_RE = /^([^\[]+)(\[.*\])?(.)?.*$/
    def CGIMethods.get_levels(key)
      all, main, bracketed, trailing = PARAMS_HASH_RE.match(key).to_a
      if main.nil?
        []
      elsif trailing
        [key]
      elsif bracketed
        [main] + bracketed.slice(1...-1).split('][')
      else
        [main]
      end
    end

    def CGIMethods.build_deep_hash(value, hash, levels)
      if levels.length == 0
        value
      elsif hash.nil?
        { levels.first => CGIMethods.build_deep_hash(value, nil, levels[1..-1]) }
      else
        hash.update({ levels.first => CGIMethods.build_deep_hash(value, hash[levels.first], levels[1..-1]) })
      end
    end
end
