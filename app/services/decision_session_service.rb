class DecisionSessionService
  def self.initiate_by_email(email: , locale: )
    decision_session = DecisionSession.create!(initiator_name: email.from[:name],
                                               initiator_email: email.from[:email],
                                               participants: harvest_particpants_from(email),
                                               locale: locale)

    DecisionSessionMailer.delay(priority: 1).setup_link(decision_session)
  end

  private
  def self.harvest_particpants_from(email)
    # filter emails so we dont have decide@loomio.org in there, and no dupes
    email.body.scan(EmailHelper.email_regex).uniq.compact
  end
end
