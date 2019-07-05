class FormatBrawl < FormatStandard
  def format_pretty_name
    "Brawl"
  end

  def deck_legality(deck)
    offending_card = deck.physical_cards.find{|card| legality(card).nil? }
    return "#{offending_card.name} is not legal in #{format_pretty_name}." unless offending_card.nil?
    offending_card = deck.physical_cards.find{|card| legality(card) == "banned" }
    return "#{offending_card.name} is banned in #{format_pretty_name}." unless offending_card.nil?
    return "The deck commander must be in the sideboard, but this deck's sideboard is empty." if deck.number_of_sideboard_cards == 0
    return "A deck can only have one commander (or two partner commanders), but this deck has #{deck.number_of_sideboard_cards}." if deck.number_of_sideboard_cards > 2
    if deck.number_of_sideboard_cards == 2
      first_partner, second_partner = deck.sideboard.map(&:last).map(&:main_front)
      return "#{first_partner.name} does not partner with #{second_partner.name}." unless first_partner.partner? and (first_partner.partner.nil? or first_partner.partner.card == second_partner.card)
      return "#{second_partner.name} does not partner with #{first_partner.name}." unless second_partner.partner? and (second_partner.partner.nil? or second_partner.partner.card == first_partner.card)
    end
    offending_card = deck.sideboard.map(&:last).find{|card| !card.brawler? }
    return "#{offending_card.name} can't be a commander." unless offending_card.nil?
    offending_card = deck.sideboard.map(&:last).find{|card| legality(card) == "restricted" }
    return "#{offending_card.name} is banned as commander in #{format_pretty_name}." unless offending_card.nil?
    mainboard_size = 60 - deck.number_of_sideboard_cards
    return "Mainboard must be exactly #{mainboard_size} cards, but this deck has #{deck.number_of_mainboard_cards}." if deck.number_of_mainboard_cards != mainboard_size
    offending_card = deck.physical_cards.map(&:main_front).find{|card| !card.allowed_in_any_number? && deck.cards_with_sideboard.select{|iter_card| iter_card.last.main_front.name == card.name}.sum(&:first) > 1 }
    unless offending_card.nil?
      count = deck.cards_with_sideboard.select{|iter_card| iter_card.last.main_front.name == offending_card.name}.sum(&:first)
      return "A maximum of one copy of the same nonbasic card is allowed, but this deck has #{count} copies of #{offending_card.name}."
    end
    deck_color_identity = deck.sideboard.map(&:last).map(&:color_identity).flat_map(&:chars).to_set
    if deck_color_identity.empty?
      first_basic_land = deck.mainboard.map(&:last).find{|card| card.types.include?("basic") and card.types.include?("land") and ["plains", "island", "swamp", "mountain", "forest"].any?{|land_type| card.types.include?(land_type) } }
      unless first_basic_land.nil?
        first_basic_land_type = first_basic_land.types.find{|land_type| ["plains", "island", "swamp", "mountain", "forest"].include(land_type) }
        second_basic_land = deck.mainboard.map(&:last).find{|card| card.types.include?("basic") and card.types.include?("land") and ["plains", "island", "swamp", "mountain", "forest"].any?{|land_type| land_type != first_basic_land_type && card.types.include?(land_type) } }
        unless second_basic_land.nil?
          second_basic_land_type = second_basic_land.types.find{|land_type| land_type != first_basic_land_type && ["plains", "island", "swamp", "mountain", "forest"].include(land_type) }
          return "#{format_pretty_name} decks with a colorless color identity may only include basic lands of a single basic land type, but this deck has both #{first_basic_land_type} and #{second_basic_land_type}."
        end
      end
      offending_card = deck.mainboard.map(&:last).find{|card| !card.color_identity.empty? and (!card.types.include?("basic") or !card.types.include?("land")) } # assumes that basic lands can only get their color identity from their basic land type
      return "The deck has a colorless color identity, but #{offending_card.name} has a color identity of #{color_identity_name(offending_card.color_identity.chars.to_set)}." unless offending_card.nil?
    else
      offending_card = deck.mainboard.map(&:last).find{|card| !(card.color_identity.chars.to_set <= deck_color_identity) }
      return "The deck has a color identity of #{color_identity_name(deck_color_identity)}, but #{offending_card.name} has a color identity of #{color_identity_name(offending_card.color_identity.chars.to_set)}." unless offending_card.nil?
    end
  end
end
