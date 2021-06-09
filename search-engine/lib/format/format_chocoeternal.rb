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
    }
  end
end