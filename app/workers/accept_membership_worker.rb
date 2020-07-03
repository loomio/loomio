class AcceptMembershipWorker
  include Sidekiq::Worker

  def perform(membership_id, user_id)
    Membership.find(membership_id).accept!(User.find(user_id))
  end
end
