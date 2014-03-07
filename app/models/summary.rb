class Summary < ActiveRecord::Base
  
  scope :of_kind,     ->(kind) {     where kind: kind }
  scope :of_length,   ->(interval) { where timeframe: "1 #{interval}" }
  scope :starting_at, ->(time) {     where start_time: time.change(sec: 0) }
  scope :for_action,  ->(action) {   where action: action }
  
  validates_uniqueness_of :kind, scope: [:start_time, :timeframe, :action]
  
  def self.last_run_time(action)
    where(action: action).maximum(:start_time)
  end
  
end