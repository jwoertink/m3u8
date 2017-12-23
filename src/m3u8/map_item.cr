module M3U8
  # MapItem represents a EXT-X-MAP tag which specifies how to obtain the Media
  # Initialization Section
  class MapItem
    property uri : String
    property byterange : ByteRange?

    def initialize(params = NamedTuple.new)
      @uri = params[:uri]
      @byterange = parse_byterange(params)
    end

    # def self.parse(text)
    #   attributes = parse_attributes(text)
    #   range_value = attributes['BYTERANGE']
    #   range = ByteRange.parse(range_value) unless range_value.nil?
    #   options = { uri: attributes['URI'], byterange: range }
    #   MapItem.new(options)
    # end

    def to_s
      %(#EXT-X-MAP:#{formatted_attributes.join(',')})
    end

    def formatted_attributes
      [
        uri_format,
        byterange_format
      ].compact
    end

    private def parse_byterange(params)
      item = params[:byterange]?
      ByteRange.new(item) unless item.nil?
    end

    private def uri_format
      %(URI="#{uri}")
    end

    private def byterange_format
      %(BYTERANGE="#{byterange.to_s}") unless byterange.nil?
    end
  end
end