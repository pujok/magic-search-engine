describe "Indexer hacks" do
  include_context "db"
  let(:index_path) { Pathname(__dir__) + "../../index/index.json" }
  let(:index_json) { index_path.read }

  it "W16 release date" do
    db.sets["w16"].release_date.should eq Date.parse("2016-04-08")
  end

  # We pretty much write whole card in indexer
  it "B.F.M. (Big Furry Monster)" do
    bfms = db.search("Big Furry Monster").printings
    bfms.size.should eq(2)
    bfms[0].name.should eq("B.F.M. (Big Furry Monster)")
    bfms[1].name.should eq("B.F.M. (Big Furry Monster, Right Side)")
    bfms.each do |bfm|
      bfm.names.should eq(["B.F.M. (Big Furry Monster)", "B.F.M. (Big Furry Monster, Right Side)"])
      bfm.layout.should eq("normal")
      bfm.colors.should eq("b")
      bfm.text.should eq("You must play both B.F.M. cards to put B.F.M. into play. If either B.F.M. card leaves play, sacrifice the other.\nB.F.M. can be blocked only by three or more creatures.")
      bfm.funny.should eq(true)
      bfm.mana_cost.should eq("{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}")
      bfm.types.should eq(["creature", "the-biggest-baddest-nastiest-scariest-creature-you'll-ever-see"])
      bfm.cmc.should eq(15)
      bfm.power.should eq(99)
      bfm.toughness.should eq(99)
      bfm.card.partial_color_identity.should eq("b")
      bfm.typeline.should eq("Creature - The-Biggest-Baddest-Nastiest-Scariest-Creature-You'll-Ever-See")
      bfm.color_identity.should eq("b")
      bfm.flavor.should eq("\"It was big. Really, really big. No, bigger than that. Even bigger. Keep going. More. No, more. Look, we're talking krakens and dreadnoughts for jewelry. It was big\"\n-Arna Kennerd, skyknight")
    end
  end

  it "is:funny" do
    assert_search_equal_cards "is:funny", "e:unh,ugl,uqc,hho,ust,pust,ppc1,htr,htr17,h17,tbth,tdag,tfth,thp1,thp2,thp3,ptg,cmb1,htr16,htr17,htr18,htr19,und,punh -(t:basic -Barry) -(Steamflogger Boss) -(Hall of Triumph)"
  end

  it "Nissa's X loyallty" do
    nissa = db.search("!Nissa, Steward of Elements").printings[0]
    nissa.loyalty.should eq("X")
  end

  it "meld card numbers" do
    db.search("is:meld").printings.map{|c| [c.set_code, c.name, c.number]}.should match_array([
      ["emn", "Brisela, Voice of Nightmares", "15b"],
      ["emn", "Bruna, the Fading Light", "15a"],
      ["emn", "Chittering Host", "96b"],
      ["emn", "Gisela, the Broken Blade", "28"],
      ["emn", "Graf Rats", "91"],
      ["emn", "Hanweir Battlements", "204"],
      ["emn", "Hanweir Garrison", "130a"],
      ["emn", "Hanweir, the Writhing Township", "130b"],
      ["emn", "Midnight Scavengers", "96a"],
      ["pemn", "Brisela, Voice of Nightmares", "15bs"],
      ["pemn", "Bruna, the Fading Light", "15as"],
      ["pemn", "Gisela, the Broken Blade", "28s"],
      ["pemn", "Hanweir Battlements", "204s"],
      ["pemn", "Hanweir Garrison", "130as"],
      ["pemn", "Hanweir, the Writhing Township", "130bs"],
      ["v17", "Brisela, Voice of Nightmares", "5b"],
      ["v17", "Bruna, the Fading Light", "5a"],
      ["v17", "Gisela, the Broken Blade", "10"],
    ])
  end

  it "rarities" do
    db.printings.map(&:rarity).to_set.should eq(
      Set["rare", "special", "common", "uncommon", "mythic", "basic"]
    )
  end

  it "&amp;" do
    index_json.should_not include("&amp;")
  end

  it "Æ" do
    bad_characters = /Æ/i
    db.printings.each do |printing|
      printing.name.should_not match(bad_characters)
      printing.text.should_not match(bad_characters)
      printing.artist.should_not match(bad_characters)
      printing.flavor.should_not match(bad_characters)
    end
  end
end
