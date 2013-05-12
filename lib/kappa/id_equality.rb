module Kappa
  # @private
  module IdEquality
    def hash
      @id.hash
    end

    def eql?(other)
      other && (self.class == other.class) && (self.id == other.id)
    end

    def ==(other)
      eql?(other)
    end
  end
end

