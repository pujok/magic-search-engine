describe "Formats - Legacy" do
  include_context "db"

  it "legacy" do
    assert_block_composition "legacy", "xln", ["lea", "leb", "2ed", "arn", "ced", "cei", "pdrc", "atq", "3ed", "leg", "drk", "fem", "plgm", "pmei", "4ed", "ice", "chr", "hml", "all", "rqs", "mir", "mgb", "itp", "vis", "5ed", "ppod", "por", "van", "wth", "ppre", "tmp", "sth", "p02", "pjgp", "exo", "palp", "usg", "ath", "ulg", "6ed", "ptk", "uds", "s99", "pgru", "pwor", "pwos", "mmq", "brb", "psus", "pfnm", "pelp", "nem", "s00", "pcy", "btd", "inv", "pls", "7ed", "pmpr", "apc", "ody", "dkm", "tor", "jud", "ons", "lgn", "scg", "8ed", "mrd", "dst", "5dn", "chk", "bok", "sok", "9ed", "rav", "p2hg", "gpt", "pcmp", "dis", "cst", "csp", "tsb", "tsp", "plc", "ppro", "pgpx", "fut", "10e", "pmgd", "psum", "med", "lrw", "evg", "mor", "plpa", "p15a", "shm", "eve", "drb", "me2", "ala", "dd2", "con", "ddc", "arb", "m10", "v09", "hop", "me3", "zen", "ddd", "h09", "wwk", "dde", "roe", "dpa", "arc", "m11", "v10", "ddf", "som", "pd2", "me4", "mbs", "ddg", "nph", "cmd", "m12", "v11", "ddh", "isd", "pd3", "dka", "ddi", "avr", "pc2", "m13", "v12", "ddj", "rtr", "cma", "gtc", "ddk", "pwcq", "dgm", "mma", "m14", "v13", "ddl", "ths", "c13", "bng", "ddm", "jou", "md1", "cns", "vma", "m15", "cp1", "cp2", "cp3", "v14", "ddn", "ktk", "c14", "dd3_evg", "dd3_dvd", "dd3_gvl", "dd3_jvc", "ugin", "frf", "ddo", "dtk", "tpr", "mm2", "ori", "v15", "ddp", "bfz", "exp", "c15", "ogw", "ddq", "soi", "w16", "ema", "emn", "v16", "cn2", "ddr", "kld", "mps", "c16", "pca", "aer", "mm3", "dds", "w17", "akh", "mp2", "cma", "e01", "hou", "c17", "xln"],
      "Amulet of Quoz" => "banned",
      "Ancestral Recall" => "banned",
      "Balance" => "banned",
      "Bazaar of Baghdad" => "banned",
      "Black Lotus" => "banned",
      "Bronze Tablet" => "banned",
      "Channel" => "banned",
      "Chaos Orb" => "banned",
      "Contract from Below" => "banned",
      "Darkpact" => "banned",
      "Demonic Attorney" => "banned",
      "Demonic Consultation" => "banned",
      "Demonic Tutor" => "banned",
      "Dig Through Time" => "banned",
      "Earthcraft" => "banned",
      "Falling Star" => "banned",
      "Fastbond" => "banned",
      "Flash" => "banned",
      "Frantic Search" => "banned",
      "Goblin Recruiter" => "banned",
      "Gush" => "banned",
      "Hermit Druid" => "banned",
      "Imperial Seal" => "banned",
      "Jeweled Bird" => "banned",
      "Library of Alexandria" => "banned",
      "Mana Crypt" => "banned",
      "Mana Drain" => "banned",
      "Mana Vault" => "banned",
      "Memory Jar" => "banned",
      "Mental Misstep" => "banned",
      "Mind Twist" => "banned",
      "Mind's Desire" => "banned",
      "Mishra's Workshop" => "banned",
      "Mox Emerald" => "banned",
      "Mox Jet" => "banned",
      "Mox Pearl" => "banned",
      "Mox Ruby" => "banned",
      "Mox Sapphire" => "banned",
      "Mystical Tutor" => "banned",
      "Necropotence" => "banned",
      "Oath of Druids" => "banned",
      "Rebirth" => "banned",
      "Sensei's Divining Top" => "banned",
      "Shahrazad" => "banned",
      "Skullclamp" => "banned",
      "Sol Ring" => "banned",
      "Strip Mine" => "banned",
      "Survival of the Fittest" => "banned",
      "Tempest Efreet" => "banned",
      "Time Vault" => "banned",
      "Time Walk" => "banned",
      "Timetwister" => "banned",
      "Timmerian Fiends" => "banned",
      "Tinker" => "banned",
      "Tolarian Academy" => "banned",
      "Treasure Cruise" => "banned",
      "Vampiric Tutor" => "banned",
      "Wheel of Fortune" => "banned",
      "Windfall" => "banned",
      "Yawgmoth's Bargain" => "banned",
      "Yawgmoth's Will" => "banned"

    assert_legality "legacy", Date.parse("2005.1.1"), "Zodiac Dog", nil
    assert_legality "legacy", Date.parse("2006.1.1"), "Zodiac Dog", "legal"
  end
end
