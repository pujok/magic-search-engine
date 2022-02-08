class FormatChocoEternal < FormatStandard
  def format_pretty_name
    "ChocoEternal"
  end

  def include_custom_sets?
    true
  end

  def rotation_schedule
    {
      "2020-06-01" => ["mh1", "ayr", "soi", "ths", "bng", "jou", "hlw", "shm", "eve", "bfz", "grn", "rna",],
      "2021-01-01" => ["mh1", "ayr", "soi", "ths", "bng", "jou", "hlw", "shm", "eve", "bfz", "grn", "rna", "dom",],
      "2021-06-20" => ["dis", "jou", "bfz", "soi", "plc", "dgm", "ldo", "dhm"],
      "2021-09-18" => ["som", "mbs", "fut", "shm", "gtc", "ayr", "tsp", "tsb"],
      "2022-02-04" => ["rak", "bbd", "mh1", "rav", "ths", "rna"],
    }
  end
end