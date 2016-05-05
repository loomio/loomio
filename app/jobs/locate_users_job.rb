class LocateUsersJob < ActiveJob::Base
  queue_as :low_priority

  def perform(active_since)
    # active_since = 50.days.ago
    Visit.select('DISTINCT(user_id) user_id, country, city, region, started_at').
          where('started_at > ?', active_since).order('started_at desc').each do |visit|
      User.where(id: visit.user_id).update_all(country: visit.country,
                                               city: visit.city,
                                               region: visit.region)
    end
  end
end
