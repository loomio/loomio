class DecisionSessionMailer < BaseMailer
  def setup_link(decision_session)
    @decision_session = decision_session
    @name = decision_session.initiator_name
    @email = decision_session.initiator_email
    @token = decision_session.token_for(@email)
    send_single_mail to: "#{@name} <#{@email}>",
                     subject_key: "email.decision_session_mailer.subject",
                     subject_params: {name: @name},
                     locale: decision_session.locale
  end
end
