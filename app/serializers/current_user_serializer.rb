class CurrentUserSerializer < UserSerializer
  attributes :email, :email_when_proposal_closing_soon, :email_missed_yesterday,
             :email_when_mentioned, :email_on_participation

  def include_gravatar_md5?
    true
  end
end
