class LocateUsersAndGroupsJob < ActiveJob::Base
  queue_as :low_priority

  def perform
    LocationService.locate_users_from_visits(within_last: '70 minutes')
    LocationService.locate_groups(active_since: 70.minutes.ago)
  end
end
