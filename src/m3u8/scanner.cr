module M3U8
  class Scanner
    getter index : Int32
    property peek_index : Int32
    property reader : Array(String)

    def initialize(string : String = "")
      @reader = string.lines.map { |line| line.strip }
      @index = 0
      @peek_index = 1
    end

    def index=(index)
      move(index: index)
    end

    def prev_index
      @index - 1
    end

    def next_index
      @index + 1
    end

    def max_index
      size - 1
    end

    def size
      @reader.size
    end

    def eof?
      @index > max_index
    end

    def rewind
      move(index: 0)
    end

    def current_line
      @reader[@index]? || ""
    end

    def prev_line
      @reader[prev_index]? || ""
    end

    def next_line
      @reader[next_index]? || ""
    end

    def next
      move(offset: 1)
    end

    def prev
      move(offset: -1)
    end

    def peek
      line = @reader[@peek_index]? || ""
      @peek_index += 1
      line
    end

    def peek_rewind
      @peek_index = next_index
    end

    def lineno
      @index + 1
    end

    def lineno=(number)
      move(index: number - 1)
    end

    def [](index : Int32)
      @reader[index]? || ""
    end

    private def set_index(index : Int32) : Nil
      @index = index
      peek_rewind
    end

    private def move(index : Int32 = @index, offset : Int32 = 0) : String?
      set_index index + offset
      current_line
    end
  end
end
