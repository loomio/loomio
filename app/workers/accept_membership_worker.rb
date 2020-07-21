class AcceptMembershipWorker
  include Sidekiq::Worker

  def perform(membership_id, user_id)
    return unless membership = Membership.pending.find_by(id: membership_id)
    user = User.find(user_id)
    MembershipService.redeem(membership: membership, actor: user, notify: false)
  end
end
