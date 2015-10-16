class CardSet
  attr_reader :set_name, :set_code, :block_name, :block_code, :border, :release_date, :printings
  def initialize(data)
    @set_name     = data["set_name"]
    @set_code     = data["set_code"]
    @block_name   = data["block_name"]
    @block_code   = data["block_code"] && data["block_code"].downcase
    @border       = data["border"]
    @release_date = data["release_date"] && Date.parse(data["release_date"])
    @printings    = Set[]
  end

  include Comparable
  def <=>(other)
    set_code <=> other.set_code
  end

  def hash
    @set_code.hash
  end
end
