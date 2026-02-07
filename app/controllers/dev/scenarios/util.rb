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
    tables = %w[
      stance_receipts omniauth_identities users groups memberships polls outcomes
      events discussions stances stance_choices poll_options tasks
      discussion_readers discussion_templates poll_templates
    ]
    retries = 0
    begin
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{tables.join(', ')} CASCADE")
    rescue ActiveRecord::Deadlocked
      retries += 1
      retry if retries < 3
      raise
    end
    ::ActionMailer::Base.deliveries = []
  end
end
