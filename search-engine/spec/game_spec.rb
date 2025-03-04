describe "Game queries" do
  include_context "db"

  it "is_digital" do
    assert_search_equal "is:digital", "e:me1,me2,me3,me4,vma,tpr,pana,pmoa,td0,td2,ana,pz1,pz2,prm,ha1,ha2,ha3,ha4,ha5,xana,past,pmic,psdg,ajmp,akr,anb,oana,klr"
  end

  it "is:paper" do
    assert_search_equal "is:paper", "game:paper"
    # This should work once everything is migrated and all issues fixed:
    # (or something like that without gold bordered / oversized / etc.)
    assert_search_results "is:paper is:digital"
    assert_search_results "is:paper border:gold"
    assert_search_results "is:paper is:oversized"
  end

  it "is:mtgo" do
    assert_search_equal "is:mtgo", "game:mtgo"
  end

  # We could have a better spec here
  it "is:arena" do
    assert_search_equal "is:arena", "game:arena"
    assert_search_equal "e:m19 is:arena", "e:m19"
    assert_search_results "e:isd is:arena"
  end

  it "is:shandalar" do
    assert_search_equal "is:shandalar", "game:shandalar"
  end

  # TODO: "is:sega"
end
