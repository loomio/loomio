module StatsHelper
  def safe_pct(amt, of)
    if of > 0 and amt > 0
      num = (amt.to_f / of.to_f * 100).round
      format('%02d', num)
    else
      0
    end
  end
end
