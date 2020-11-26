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

    outcome.assign_attributes(author: actor)
    return false unless outcome.valid?
    outcome.poll.outcomes.update_all(latest: false)
    outcome.store_calendar_invite if outcome.should_send_calendar_invite

    outcome.save!

    users = UserInviter.where_or_create!(inviter: actor,
                                         emails: params[:recipient_emails],
                                         user_ids: params[:recipient_user_ids],
                                         model: outcome,
                                         audience: params[:recipient_audience])

    EventBus.broadcast 'outcome_create', outcome, actor

    Events::OutcomeCreated.publish!(outcome: outcome,
                                    recipient_user_ids: users.pluck(:id),
                                    recipient_audience: params[:recipient_audience])
  end

  def self.update(outcome:, actor:, params: {})
    actor.ability.authorize! :update, outcome

    HasRichText.assign_attributes_and_update_files(outcome, params)
    outcome.assign_attributes(params.slice(:statement, :statement_format))
    return false unless outcome.valid?
    outcome.store_calendar_invite if outcome.should_send_calendar_invite

    outcome.save!

    users = UserInviter.where_or_create!(inviter: actor,
                                         emails: params[:recipient_emails],
                                         user_ids: params[:recipient_user_ids],
                                         model: outcome,
                                         audience: params[:recipient_audience])

    EventBus.broadcast 'outcome_update', outcome, actor

    Events::OutcomeUpdated.publish!(outcome: outcome,
                                    actor: actor,
                                    recipient_user_ids: users.pluck(:id),
                                    recipient_audience: params[:recipient_audience])
  end

  def self.publish_review_due
    Outcome.review_due_not_published(Date.today).each do |outcome|
      Events::OutcomeReviewDue.publish!(outcome)
    end
  end

end
