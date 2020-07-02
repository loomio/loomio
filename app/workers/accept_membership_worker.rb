class AcceptMembershipWorker
  include Sidekiq::Worker

  def perform(membership_id)
    Membership.find(membership_id).accept!
  end
end
