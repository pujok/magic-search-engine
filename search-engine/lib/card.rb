# This class represents card from index point of view, not from data point of view
# (thinking in solr/lucene terms)
require "date"
require_relative "ban_list"
require_relative "legality_information"

class Card
  ABILITY_WORD_LIST = [
    "Adamant",
    "Addendum",
    "Battalion",
    "Bloodrush",
    "Channel",
    "Chroma",
    "Cohort",
    "Constellation",
    "Converge",
    "Council's dilemma",
    "Delirium",
    "Domain",
    "Eminence",
    "Enrage",
    "Fateful hour",
    "Ferocious",
    "Formidable",
    "Gotcha",
    "Grandeur",
    "Hellbent",
    "Hero's Reward",
    "Heroic",
    "Imprint",
    "Inspired",
    "Join forces",
    "Kinfall",
    "Kinship",
    "Landfall",
    "Landship",
    "Legacy",
    "Lieutenant",
    "Magecraft",
    "Metalcraft",
    "Morbid",
    "Parley",
    "Radiance",
    "Raid",
    "Rally",
    "Requirement",
    "Revolt",
    "Spell mastery",
    "Strive",
    "Sweep",
    "Tempting offer",
    "Threshold",
    "Underdog",
    "Undergrowth",
    "Will of the council",
  ]
  ABILITY_WORD_RX = %r[^(#{Regexp.union(ABILITY_WORD_LIST)}) —]i

  attr_reader :data, :printings
  attr_writer :printings # For db subset

  attr_reader :name, :names, :layout, :colors, :mana_cost, :reserved, :types
  attr_reader :partial_color_identity, :cmc, :text, :text_normalized, :power, :toughness, :loyalty, :extra
  attr_reader :hand, :life, :rulings, :foreign_names, :foreign_names_normalized, :stemmed_name
  attr_reader :mana_hash, :typeline, :funny, :color_indicator, :color_indicator_set, :related
  attr_reader :reminder_text, :augment, :display_power, :display_toughness, :display_mana_cost, :keywords

  def initialize(data)
    @printings = []
    @name = data["name"]
    @stemmed_name = -@name.downcase.normalize_accents.gsub(/s\b/, "").tr("-", " ")
    @names = data["names"]
    @layout = data["layout"]
    @colors = data["colors"] || ""
    @funny = data["funny"]
    @text = (data["text"] || "")
    @text = @text.gsub(/\s*\([^\(\)]*\)/, "") unless @funny
    @text = -@text.sub(/\s*\z/, "").gsub(/ *\n/, "\n").sub(/\A\s*/, "")
    @text_normalized = -@text.normalize_accents
    @augment = !!(@text =~ /augment \{/i)
    @mana_cost = data["manaCost"]
    @reserved = data["reserved"] || false
    @types = ["types", "subtypes", "supertypes"]
      .flat_map{|t| data[t] || []}
      .map{|t| -t.downcase.tr("’\u2212", "'-").gsub("'s", "").tr(" ", "-")}
    @cmc = data["cmc"] || 0
    @power = data["power"] ? smart_convert_powtou(data["power"]) : nil
    @toughness = data["toughness"] ? smart_convert_powtou(data["toughness"]) : nil
    @loyalty = data["loyalty"] ? smart_convert_powtou(data["loyalty"]) : nil
    @display_power = data["display_power"] ? data["display_power"] : @power
    @display_toughness = data["display_toughness"] ? data["display_toughness"] : @toughness
    @display_mana_cost = data["hide_mana_cost"] ? nil : @mana_cost
    @partial_color_identity = calculate_partial_color_identity
    if ["vanguard", "planar", "scheme"].include?(@layout) or @types.include?("conspiracy")
      @extra = true
    else
      @extra = false
    end
    @hand = data["hand"]
    @life = data["life"]
    @rulings = data["rulings"]
    @secondary = data["secondary"]
    @partner = data["is_partner"]
    if data["foreign_names"]
      @foreign_names = data["foreign_names"].map{|k,v| [k.to_sym,v]}.to_h
    else
      @foreign_names = {}
    end
    @foreign_names_normalized = {}
    @foreign_names.each do |lang, names|
      @foreign_names_normalized[lang] = names.map{|n| hard_normalize(n)}
    end
    @related = data["related"]
    @typeline = [data["supertypes"], data["types"]].compact.flatten.join(" ")
    if data["subtypes"]
      @typeline += " - #{data["subtypes"].join(" ")}"
    end
    @typeline = -@typeline
    if data["keywords"]
      @keywords = data["keywords"].map{|k| -k}
    end
    calculate_mana_hash
    calculate_color_indicator
    calculate_reminder_text
  end

  def partner?
    !!@partner
  end

  def front?
    !@secondary or @layout == "aftermath" or @layout == "flip" or @layout == "adventure"
  end

  def back?
    !front?
  end

  def primary?
    !@secondary
  end

  def secondary?
    @secondary
  end

  attr_writer :color_identity
  def color_identity
    @color_identity ||= begin
      return partial_color_identity unless @names
      raise "Multi-part cards need to have CI set by database"
    end
  end

  def custom?
    # a card is custom if it has been printed in at least one custom set (to exclude uncards)...
    return false unless printings.any? { |printing| printing.set.custom? }
    # ...and hasn't been printed in an official black-border set (to exclude custom reprints of official cards)
    printings.all? { |printing| printing.set.custom? or printing.set.funny? }
  end

  def has_multiple_parts?
    !!@names
  end

  def inspect
    "Card(#{name})"
  end

  include Comparable
  def <=>(other)
    name <=> other.name
  end

  def to_s
    inspect
  end

  def legality_information(date=nil)
    LegalityInformation.new(self, date)
  end

  def first_release_date
    @first_release_date ||= @printings.map(&:release_date).compact.min
  end

  def first_regular_release_date
    @first_regular_release_date ||= @printings
      .select{|cp| cp.set_code != "ppre"}
      .map(&:release_date)
      .compact
      .min
  end

  def last_release_date
    @last_release_date ||= @printings.map(&:release_date).compact.max
  end

  def allowed_in_any_number?
    @types.include?("basic") or (
      @text and @text.include?("A deck can have any number of cards named")
    )
  end

  def commander?
    return false if @secondary
    return true if @types.include?("legendary") and @types.include?("creature")
    if @types.include?("planeswalker")
      return true if @text.include?("can be your commander")
    end
    if @types.include?("saga")
      return true if @text.include?("can be your commander")
    end
    false
  end

  def brawler?
    return false if @secondary
    return true if @types.include?("legendary") and (@types.include?("creature") or @types.include?("planeswalker"))
    false
  end

  private

  def calculate_mana_hash
    if @mana_cost.nil?
      @mana_hash = nil
      return
    end
    @mana_hash = Hash.new(0)

    mana = @mana_cost.gsub(/\{(.*?)\}/) do
      m = $1
      case m
      when /\A\d+\z/
        @mana_hash["?"] += m.to_i
      when /\A[wubrgxyzcs]\z/
        # x is basically a color for this kind of queries
        @mana_hash[m] += 1
      when /\Ah([wubrg])\z/
        @mana_hash[$1] += 0.5
      when /\A([wubrg])\/([wubrg])\z/
        @mana_hash[normalize_mana_symbol(m)] += 1
      when /\A([wubrg])\/p\z/
        @mana_hash[normalize_mana_symbol(m)] += 1
      when /\A2\/([wubrg])\z/
        @mana_hash[normalize_mana_symbol(m)] += 1
      else
        raise "Unrecognized mana type: #{m}"
      end
      ""
    end
    raise "Mana query parse error: #{mana}" unless mana.empty?
  end

  def normalize_mana_symbol(sym)
    -sym.downcase.tr("/{}", "").chars.sort.join
  end

  def hard_normalize(s)
    -s.unicode_normalize(:nfd).gsub(/\p{Mn}/, "").downcase
  end

  def smart_convert_powtou(val)
    return val unless val.is_a?(String)
    # Treat augment "+1"/"-1" strings as regular 1/-1 numbers for search engine
    # The view can use special format for them
    return val.to_i if val =~ /\A\+\d+\z/
    if val !~ /\A-?[\d.]+\z/
      # It just so happens that "2+*" > "1+*" > "*" asciibetically
      # so we don't do any extra conversions,
      # but we might need to setup some eventually
      #
      # Including uncards
      # "*" < "*²" < "1+*" < "2+*"
      # but let's not get anywhere near that
      case val
      when "*", "*²", "1+*", "2+*", "7-*", "X", "∞", "?", "1d4+1"
        val
      else
        raise "Unrecognized value #{val.inspect}"
      end
    elsif val.to_i == val.to_f
      val.to_i
    else
      val.to_f
    end
  end

  def calculate_partial_color_identity
    ci = colors.chars
    "#{mana_cost} #{text}".scan(/{(.*?)}/).each do |sym,|
      case sym.downcase
      when /\A(\d+|[½∞txyzsqpceav])\z/
        # 12xyz - colorless
        # ½∞ - unset colorless
        # t - tap
        # q - untap
        # s - snow
        # p - generic Phyrexian mana (like on Rage Extractor text)
        # c - colorless mana
        # e - energy
        # a - acorn
      when /\A([wubrg])\z/
        ci << $1
      when /\A([wubrg])\/p\z/
        # Phyrexian mana
        ci << $1
      when /\Ah([wubrg])\z/
        # Unset half colored mana
        ci << $1
      when /\A2\/([wubrg])\z/
        ci << $1
      when /\A([wubrg])\/([wubrg])\z/
        ci << $1 << $2
      when "chaos"
        # planechase special symbol, disregard
      when "+1"
        # loyaty symbol, on Carth the Lion
      else
        raise "Unknown mana symbol `#{sym}'"
      end
    end
    types.each do |t|
      tci = {"forest" => "g", "mountain" => "r", "plains" => "w", "island" => "u", "swamp" => "b"}[t]
      ci << tci if tci
    end
    -ci.sort.uniq.join
  end

  def calculate_color_indicator
    colors_inferred_from_mana_cost = (@mana_hash || {}).keys
      .flat_map do |x|
        next [] if x =~ /[?xyzcs]/
        x = x.sub(/[p2]/, "")
        if x =~ /\A[wubrg]+\z/
          x.chars
        else
          raise "Unknown mana cost: #{x}"
        end
      end
      .uniq

    actual_colors = @colors.chars

    if colors_inferred_from_mana_cost.sort == actual_colors.sort
      @color_indicator = nil
    else
      @color_indicator = Color.color_indicator_name(actual_colors)
    end
    if @color_indicator
      @color_indicator_set = actual_colors.to_set
    end
  end

  def calculate_reminder_text
    @reminder_text = nil
    basic_land_types = (["forest", "island", "mountain", "plains", "swamp"] & @types.to_a)
      .sort.join(" ")
    if not basic_land_types.empty?
      # Listing them all explicitly due to wubrg wheel order
      mana = case basic_land_types
      when "plains"
        "{W}"
      when "island"
        "{U}"
      when "swamp"
        "{B}"
      when "mountain"
        "{R}"
      when "forest"
        "{G}"
      when "island plains"
        "{W} or {U}"
      when "plains swamp"
        "{W} or {B}"
      when "island swamp"
        "{U} or {B}"
      when "island mountain"
        "{U} or {R}"
      when "mountain swamp"
        "{B} or {R}"
      when "forest swamp"
        "{B} or {G}"
      when "forest mountain"
        "{R} or {G}"
      when "mountain plains"
        "{R} or {W}"
      when "forest plains"
        "{G} or {W}"
      when "forest island"
        "{G} or {U}"
      when "forest plains swamp"
        "{W}, {B}, or {G}"
      when "forest island mountain"
        "{G}, {U}, or {R}"
      when "island mountain plains"
        "{U}, {R}, or {W}"
      when "mountain plains swamp"
        "{R}, {W}, or {B}"
      when "forest island swamp"
        "{B}, {G}, or {U}"
      else
        raise "No idea what's correct line for #{basic_land_types.inspect}"
      end
      @reminder_text = "({T}: Add #{mana}.)"
    elsif layout == "flip" and secondary?
      # Awkward wording
      other_name = (@names - [@name])[0]
      @reminder_text = "(#{@name} keeps color and mana cost of #{other_name} when flipped)"
    end
  end
end
