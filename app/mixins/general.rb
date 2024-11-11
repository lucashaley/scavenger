class String
  def linebreaked
    self.gsub(",", "\n")
  end
end

class Array
  def add_2d(b)
    raise ArgumentError if count != b.count

    [
      self[0] + b[0],
      self[1] + b[1]
    ]
  end
end

class Integer
  def frames
    # This does nothing
    # But it provides context
    self
  end
end