module Dev::Scenarios::Util
  def accept_last_invitation
    membership = Membership.pending.last
    MembershipService.redeem(membership: invitation, actor: max)
    redirect_to(group_path(membership.group))
  end

  def use_last_login_token
    redirect_to(login_token_path(::LoginToken.last.token), allow_other_host: true)
  end

  private

  def cleanup_database
    reset_session
    ::User.delete_all
    ::Group.delete_all
    ::Membership.delete_all
    ::Poll.delete_all
    ::Outcome.delete_all
    ::Event.delete_all
    ::Discussion.delete_all
    ::Stance.delete_all
    ::StanceChoice.delete_all
    ::PollOption.delete_all
    ::Task.delete_all
    ::DiscussionReader.delete_all
    ::DiscussionTemplate.delete_all
    ::PollTemplate.delete_all
    ::ActionMailer::Base.deliveries = []
  end
end
