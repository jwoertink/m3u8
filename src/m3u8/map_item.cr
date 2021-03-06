module M3U8
  # MapItem represents a EXT-X-MAP tag which specifies how to obtain the Media
  # Initialization Section
  class MapItem
    include Concern

    property uri : String
    property byterange : ByteRange

    # ```
    # text = %(#EXT-X-MAP:URI="frelo/prog_index.m3u8",BYTERANGE="4500@600")
    # MapItem.parse(text)
    # # => #<M3U8::MapItem......>
    # ```
    def self.parse(text)
      params = parse_attributes(text)
      new(
        uri: params["URI"],
        byterange: ByteRange.parse(params["BYTERANGE"]?),
      )
    end

    # ```
    # options = {
    #   uri:       "frelo/prog_index.m3u8",
    #   byterange: {
    #     length: 4500,
    #     start:  600,
    #   },
    # }
    # MapItem.new(options)
    #
    # options = {
    #   uri:       "frelo/prog_index.m3u8",
    #   byterange: ByteRange.new(length: 4500, start: 600),
    # }
    # MapItem.new(options)
    #
    # options = {
    #   uri:       "frelo/prog_index.m3u8",
    #   byterange: "4500@600",
    # }
    # MapItem.new(options)
    # ```
    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        uri: params[:uri],
        byterange: params[:byterange]?
      )
    end

    # ```
    # uri = "frelo/prog_index.m3u8"
    # byterange = "4500@600"
    # MapItem.new(uri)
    # MapItem.new(uri, byterange)
    # MapItem.new(uri: uri)
    # MapItem.new(uri: uri, byterange: byterange)
    # ```
    def initialize(@uri, byterange = nil)
      @byterange = ByteRange.parse(byterange)
    end

    # ```
    # options = {
    #   uri:       "frelo/prog_index.m3u8",
    #   byterange: "4500@600",
    # }
    # MapItem.new(options).to_s
    # # => %(#EXT-X-MAP:URI="frelo/prog_index.m3u8",BYTERANGE="4500@600")
    # ```
    def to_s
      %(#EXT-X-MAP:#{attributes.join(',')})
    end

    private def attributes
      [
        uri_format,
        byterange_format,
      ].compact
    end

    private def uri_format
      %(URI="#{uri}")
    end

    private def byterange_format
      %(BYTERANGE="#{byterange.to_s}") unless byterange.empty?
    end
  end
end
