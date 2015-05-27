module StatsHelper
  def safe_pct(amt, of)
    if of > 0 and amt > 0
      amt.to_f / of.to_f * 100
    else
      0
    end.round
  end
end
