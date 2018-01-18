module M3U8
  class Parser
    property playlist : Playlist

    @live : Bool?
    @open : Bool?
    @item : Items?

    def initialize(string : String)
      @reader = Scanner.new string
      @lineno = 0

      @playlist = M3U8::Playlist.new
      @live = nil
      @open = nil
      @item = nil
      @extm3u = true
    end

    def self.read(string : String)
      new(string).read
    end

    def read
      @reader.each do |line|
        parse line
      end

      @playlist.live = true if !@playlist.master && @live.nil?

      raise "missing #EXTM3U tag" if @extm3u

      @playlist
    end

    def parse(line)
      tag, del, value = line.partition(':')

      if BASIC_TAGS.includes? tag
      end
      if MEDIA_SEGMENT_TAGS.includes? tag
        not_master!
      end
      if MEDIA_PLAYLIST_TAGS.includes? tag
        not_master!
      end
      if MASTER_PLAYLIST_TAGS.includes? tag
        master!
      end
      if MASTER_MEDIA_PLAYLIST_TAGS.includes? tag
      end
      if EXPERIMENTAL_TAGS.includes? tag
      end


      # Basic Tags
      case tag
      when EXTM3U
        @extm3u = false
      when EXT_X_VERSION
        @playlist.version = value.to_i

      # media segment tags
      when EXTINF
        item = SegmentItem.new

        duration, comment = value.split(',')
        item.duration = duration.to_f
        item.comment = comment

        @open = true
        @item = item

      when EXT_X_BYTERANGE
        item = @item
        item.byterange = value if item.is_a?(SegmentItem)
        @item = item

      when EXT_X_DISCONTINUITY
        push_item DiscontinuityItem.new

      when EXT_X_KEY

      when EXT_X_MAP

      when EXT_X_PROGRAM_DATE_TIME
        item = @item
        case item
        when SegmentItem
          item.program_date_time = value
          @item = item
        when Nil
          push_item TimeItem.new(value)
        end

      when EXT_X_DATERANGE

      # Media Playlist Tags
      when EXT_X_TARGETDURATION
        @playlist.target = value.to_f

      when EXT_X_MEDIA_SEQUENCE
        @playlist.sequence = value.to_i

      when EXT_X_DISCONTINUITY_SEQUENCE
        @playlist.discontinuity_sequence = value.to_i

        # EXT-X-DISCONTINUITY-SEQUENCE:8

      when EXT_X_ENDLIST
        @live = false

      when EXT_X_PLAYLIST_TYPE
        @playlist.type = value

      when EXT_X_I_FRAMES_ONLY
        @playlist.iframes_only = true

      when EXT_X_ALLOW_CACHE
        @playlist.cache = value.to_boolean

      # Master Playlist Tags
      when EXT_X_MEDIA
        @playlist.master = true

      when EXT_X_STREAM_INF
        @item = PlaylistItem.new

        parse_playlist_item(value)

      when EXT_X_I_FRAME_STREAM_INF

      when EXT_X_SESSION_DATA

      when EXT_X_SESSION_KEY
        push_item parse_session_key_item(value)

      # Media or Master Playlist Tags
      when EXT_X_INDEPENDENT_SEGMENTS
        @playlist.independent_segments = true

      when EXT_X_START

      when '#'
        pp line
        # comment
        # pass
      else
        parse_item line
      end
    end

    def parse_item(line)
      item = @item
      case item
      when SegmentItem
        item.segment = line
        push_item
      when PlaylistItem
        item.uri = line
        push_item
      else
        puts "can't cache this line: #{line}"
      end
    end

    private def push_item(item = @item)
      @playlist.items << item if item
      @item = nil
    end

    private def master!
      raise "invalid playlist. both both playlist tag and media tag." if @playlist.master == false
      @playlist.master = true
    end

    private def not_master!
      raise "invalid playlist. both both playlist tag and media tag." if @playlist.master == true
      @playlist.master = false
    end

    def parse_attributes(line)
      array = line.scan(/([A-z0-9-]+)\s*=\s*("[^"]*"|[^,]*)/)
      array.map { |reg| [reg[1], reg[2].delete('"')] }.to_h
    end

    def parse_session_key_item(text)
      attributes = parse_attributes(text)
      options = session_key_attributes(attributes)
      SessionKeyItem.new(options)
    end

    def session_key_attributes(attributes)
      {
        method: attributes["METHOD"],
        uri: attributes["URI"]?,
        iv: attributes["IV"]?,
        key_format: attributes["KEYFORMAT"]?,
        key_format_versions: attributes["KEYFORMATVERSIONS"]?,
      }
    end

    def parse_playlist_item(value)
      attributes = parse_attributes(value)
      options = options_from_attributes(attributes)
      Playlist.new(options)
    end

    private def options_from_attributes(attributes)
      resolution = parse_resolution(attributes["RESOLUTION"]?)
      {
        program_id: attributes["PROGRAM-ID"]?,
        codecs: attributes["CODECS"]?,
        width: resolution[:width]?,
        height: resolution[:height]?,
        bandwidth: attributes["BANDWIDTH"]?.try &.to_i,
        average_bandwidth: parse_average_bandwidth(attributes["AVERAGE-BANDWIDTH"]?),
        frame_rate: parse_frame_rate(attributes["FRAME-RATE"]?),
        video: attributes["VIDEO"]?,
        audio: attributes["AUDIO"]?,
        uri: attributes["URI"]?,
        subtitles: attributes["SUBTITLES"]?,
        closed_captions: attributes["CLOSED-CAPTIONS"]?,
        name: attributes["NAME"]?,
        hdcp_level: attributes["HDCP-LEVEL"]?
      }
    end

    def parse_average_bandwidth(value)
      value.to_i unless value.nil?
    end

    def parse_resolution(resolution)
      return { width: nil, height: nil } if resolution.nil?

      values = resolution.split('x')
      {
        width: values[0].to_i,
        height: values[1].to_i
      }
    end

    def parse_frame_rate(frame_rate)
      return if frame_rate.nil?

      value = BigDecimal.new(frame_rate)
      value if value > 0
    end
  end
end
