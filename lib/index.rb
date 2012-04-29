module AlacIt
  class Index
    SECONDS_PER_MINUTE = 60
    FRAMES_PER_SECOND = 75
    FRAMES_PER_MINUTE = FRAMES_PER_SECOND * 60

    attr_reader :minutes, :seconds, :frames

    def initialize(value=nil)
      case value
      when Array
        set_from_array!(value)
      when Integer
        set_from_integer!(value)
      end
    end

    def to_f
      ((@minutes * SECONDS_PER_MINUTE) + (@seconds) + (@frames.to_f / FRAMES_PER_SECOND)).to_f
    end

    def to_i
      to_f.floor
    end

    def to_a
      [@minutes, @seconds, @frames]
    end

    def to_s
      "#{'%02d' % @minutes}:#{'%02d' % @seconds}:#{'%02d' % @frames}"
    end

    def to_human_ms
      "00:#{'%02d' % @minutes}:#{'%02d' % @seconds}" + (@frames.to_f / 75).round(3).to_s[1..-1]
    end

    def +(other)
      self.class.new(carrying_addition(other))
    end

    def -(other)
      self.class.new(carrying_subtraction(other))
    end

    def >(other)
      self.to_f > other.to_f
    end

    def <(other)
      self.to_f < other.to_f
    end

    def ==(other)
      self.to_a == other.to_a
    end

    def each
      to_a.each { |value| yield value }
    end

    private

    def carrying_addition(other)
      minutes, seconds, frames = *[@minutes + other.minutes, 
        @seconds + other.seconds, @frames + other.frames]

      seconds, frames = *convert_with_rate(frames, seconds, FRAMES_PER_SECOND)
      minutes, seconds = *convert_with_rate(seconds, minutes, SECONDS_PER_MINUTE)
      [minutes, seconds, frames]
    end

    def carrying_subtraction(other)
      seconds = minutes = 0

      my_frames = @frames + (@seconds * FRAMES_PER_SECOND) + (@minutes * FRAMES_PER_MINUTE)
      other_frames = other.frames + (other.seconds * FRAMES_PER_SECOND) + (other.minutes * FRAMES_PER_MINUTE)
      frames = my_frames - other_frames

      seconds, frames = *convert_with_rate(frames, seconds, FRAMES_PER_SECOND)
      minutes, seconds = *convert_with_rate(seconds, minutes, SECONDS_PER_MINUTE)
      [minutes, seconds, frames]
    end

    def convert_with_rate(from, to, rate, step=1)
      while from >= rate
        to += step
        from -= rate
      end
      [to, from]
    end

    def set_from_array!(array)
      if array.size != 3 || array.any?{|element| !element.is_a?(Integer)}
        raise ArgumentError.new("Must be initialized with an array in the format of [minutes, seconds,frames], all integers")
      end
      @minutes, @seconds, @frames = *array
    end

    def set_from_integer!(seconds)
      @minutes = 0
      @frames = 0
      @seconds = seconds

      while @seconds >= SECONDS_PER_MINUTE
        @minutes += 1
        @seconds -= SECONDS_PER_MINUTE
      end
    end

  end
end