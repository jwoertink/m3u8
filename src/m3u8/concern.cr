module M3U8
  private module Concern
    private macro included
      extend Concern
    end

    private def parse_attributes(line : String)
      array = line.scan(/([A-z0-9-]+)\s*=\s*("[^"]*"|[^,]*)/)
      array.map { |reg| [reg[1], reg[2].delete('"')] }.to_h
    end

    private def parse_client_attributes(attributes)
      hash = ClientAttributeType.new
      return hash if !attributes

      attributes.each do |key, value|
        next unless key.is_a?(String) && key.starts_with?("X-")

        value = parse_token(value) if value.is_a?(String)

        hash[key] = value
      end
      hash
    end

    private def parse_token(token : String)
      case token
      when .to_f?  then token.to_f
      when .to_i?  then token.to_i
      when "true"  then true
      when "false" then false
      when .empty? then ""
      else              token
      end
    end

    private def parse_resolution(resolution)
      return {width: nil, height: nil} if resolution.nil?

      values = resolution.split('x')
      {
        width:  values[0].to_i,
        height: values[1].to_i,
      }
    end

    private def parse_frame_rate(frame_rate)
      return if frame_rate.nil?

      value = BigDecimal.new(frame_rate)
      value if value > 0
    end

    private def parse_yes_no(value)
      case value
      when true  then "YES"
      when false then "NO"
      end
    end

    private def parse_boolean(value)
      case value
      when "true", "YES" then true
      when "false", "NO" then false
      end
    end

    private macro method_missing(call)
      nil
    end
  end
end
