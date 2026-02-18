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

end
