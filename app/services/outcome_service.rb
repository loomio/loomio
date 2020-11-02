class OutcomeService
  def self.announce(outcome:, actor:, params:)
    actor.ability.authorize! :announce, outcome

    users = UserInviter.where_or_create!(inviter: actor,
                                         emails: params[:recipient_emails],
                                         user_ids: params[:recipient_user_ids])
    Events::OutcomeAnnounced.publish!(outcome, actor, users.pluck(:id), params[:recipient_audience])
    users
  end

  def self.create(outcome:, actor:, params: {})
    actor.ability.authorize! :create, outcome
    actor.ability.authorize! :announce, outcome if params[:recipient_audience]

    outcome.assign_attributes(author: actor)
    return false unless outcome.valid?
    outcome.poll.outcomes.update_all(latest: false)
    outcome.store_calendar_invite if outcome.should_send_calendar_invite

    outcome.save!

    users = UserInviter.where_or_create!(inviter: actor,
                                         emails: params[:recipient_emails],
                                         user_ids: params[:recipient_user_ids])
    audience_ids = AnnouncementService.audience_users(outcome, params[:recipient_audience]).pluck(:id)

    EventBus.broadcast 'outcome_create', outcome, actor
    Events::OutcomeCreated.publish!(outcome: outcome, user_ids: users.pluck(:id).concat(audience_ids))
  end

  def self.update(outcome:, actor:, params: {})
    actor.ability.authorize! :update, outcome
    actor.ability.authorize! :announce, outcome if params[:recipient_audience]

    HasRichText.assign_attributes_and_update_files(outcome, params)
    outcome.assign_attributes(params.slice(:statement, :statement_format))
    outcome.assign_attributes(author: actor)
    return false unless outcome.valid?
    outcome.store_calendar_invite if outcome.should_send_calendar_invite

    outcome.save!

    outcome.update_versions_count

    users = UserInviter.where_or_create!(inviter: actor,
                                         emails: params[:recipient_emails],
                                         user_ids: params[:recipient_user_ids])
    audience_ids = AnnouncementService.audience_users(outcome, params[:recipient_audience]).pluck(:id)

    EventBus.broadcast 'outcome_update', outcome, actor
    Events::OutcomeUpdated.publish!(outcome: outcome, user_ids: users.pluck(:id).concat(audience_ids))
  end

end
