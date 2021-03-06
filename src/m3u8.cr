require "big"
require "./patch/*"
require "./m3u8/concern"
require "./m3u8/*"

module M3U8
  private alias Items = SegmentItem | PlaylistItem | SessionDataItem | KeyItem | TimeItem | DiscontinuityItem | SessionKeyItem | PlaybackStart | MediaItem | MapItem | DateRangeItem
  private alias ClientAttributeType = Hash(String | Symbol, String | Int32 | Float64 | Bool | Nil)

  include Protocol
end
