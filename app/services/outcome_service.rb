class OutcomeService
  # def self.announce(outcome:, actor:, params:)
  #   actor.ability.authorize! :announce, outcome
  #
  #   users = userinviter.where_or_create!(inviter: actor, emails: params[:emails], user_ids: params[:user_ids])
  #   events::outcomeannounced.publish!(outcome, actor, users)
  #   users
  # end

  def self.create(outcome:, actor:, params: {})
    actor.ability.authorize! :create, outcome

    outcome.assign_attributes(author: actor)
    return false unless outcome.valid?
    outcome.poll.outcomes.update_all(latest: false)
    outcome.store_calendar_invite if outcome.should_send_calendar_invite
    # puts params[:notify_audience], params[:recipient_emails], params[:recipient_user_ids]

    outcome.save!

    EventBus.broadcast 'outcome_create', outcome, actor
    Events::OutcomeCreated.publish!(outcome, user: actor,
      recipients: users_to_notify(outcome: outcome, params: params, actor: actor))
  end

  def self.update(outcome:, actor:, params: {})
    actor.ability.authorize! :update, outcome

    HasRichText.assign_attributes_and_update_files(outcome, params.except(:document_ids))
    outcome.assign_attributes(params.slice(:statement))
    outcome.assign_attributes(author: actor)
    return false unless outcome.valid?
    outcome.store_calendar_invite if outcome.should_send_calendar_invite

    outcome.save!

    outcome.update_versions_count
    EventBus.broadcast 'outcome_create', outcome, actor
    Events::OutcomeCreated.publish!(outcome, user: actor,
      recipients: users_to_notify(outcome: outcome, params: params, actor: actor))
  end

  def self.users_to_notify(outcome:, params:, actor:)
    user_ids = Array(params[:recipient_user_ids]).map(&:to_i)
    emails = Array(params[:recipient_emails])
    audience = params[:recipient_audience]
    user_ids = Array(user_ids).concat AnnouncementService.audience_for(outcome, audience, actor).pluck('users.id')
    UserInviter.where_or_create!(inviter: actor, user_ids: user_ids, emails: emails)
  end
end
