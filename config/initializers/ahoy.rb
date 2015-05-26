class Ahoy::Store < Ahoy::Stores::ActiveRecordStore
  Ahoy.cookie_domain = :all
  Ahoy.visit_duration = 30.minutes
  Ahoy.geocode = :async
  Ahoy.track_visits_immediately = true if Rails.env.test?
end
