class SummaryService

  def self.create_summary(time: nil, models: [], action: nil)
    granularity = granularity(time)
    models.each do |model|
      summarize_timeframe model, time.change(sec: 0),    action, :minute if granularity <= 1.minute
      summarize_timeframe model, time.beginning_of_hour, action, :hour   if granularity <= 1.hour && time.min == 0
      summarize_timeframe model, time.beginning_of_day,  action, :day    if granularity <= 1.day  && time.min == 0 && time.hour == 0
    end
  end
  
  def self.granularity(time)
    if time < 1.month.ago(Time.now)
      1.day
    elsif time < 1.week.ago(Time.now)
      1.hour
    else
      1.minute
    end
  end
  
  private
  
  def self.summarize_timeframe(model, time, action, timeframe)    
    start_time = 1.send(timeframe).ago(time)
    count = model.where("age(#{action}, timestamp ?) between interval '0 #{timeframe}' and interval '1 #{timeframe}'", start_time).count
    result = Summary.create kind:           model.to_s.downcase.to_sym, 
                            start_time:     start_time,
                            timeframe:      "1 #{timeframe}",
                            action:         action,
                            count:          count
    puts "created summary for #{model.to_s.pluralize} which where #{action} in the #{timeframe} of #{start_time}" if result.valid?
  end

end