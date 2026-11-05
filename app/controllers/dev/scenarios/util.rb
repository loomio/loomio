module Dev::Scenarios::Util
  def accept_last_invitation
    membership = Membership.pending.last
    MembershipService.redeem(membership: invitation, actor: max)
    redirect_to(group_path(membership.group))
  end

  def use_last_login_token
    redirect_to(login_token_path(::LoginToken.last.token), allow_other_host: true)
  end

  # Let E2E specs take the collaboration server away and bring it back
  # empty, as a restart would. Affects only the Puma worker that serves the
  # request, so E2E runs use one worker.
  def collab_server_stop
    CollabServer.server.stop
    head :ok
  end

  def collab_server_start
    CollabServer.server.start
    head :ok
  end

  private

end
