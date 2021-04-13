class OutcomeService
  def self.invite(outcome:, actor:, params:)
    actor.ability.authorize! :announce, outcome

    UserInviter.authorize!(user_ids: params[:recipient_user_ids],
                           emails: params[:recipient_emails],
                           audience: params[:recipient_audience],
                           model: outcome,
                           actor: actor)

    users = UserInviter.where_or_create!(actor: actor,
                                         model: outcome,
                                         emails: params[:recipient_emails],
                                         user_ids: params[:recipient_user_ids],
                                         audience: params[:recipient_audience],
                                         include_actor: params[:include_actor].present?)

    Events::OutcomeAnnounced.publish!(outcome, actor, users.pluck(:id), params[:recipient_audience])
    users
  end

  def self.create(outcome:, actor:, params: {})
    actor.ability.authorize! :create, outcome

    UserInviter.authorize!(user_ids: params[:recipient_user_ids],
                           emails: params[:recipient_emails],
                           audience: params[:recipient_audience],
                           model: outcome,
                           actor: actor)

    outcome.assign_attributes(author: actor)
    return false unless outcome.valid?
    outcome.poll.outcomes.update_all(latest: false)
    outcome.store_calendar_invite if outcome.should_send_calendar_invite

    outcome.save!

    users = UserInviter.where_or_create!(actor: actor,
                                         emails: params[:recipient_emails],
                                         user_ids: params[:recipient_user_ids],
                                         model: outcome,
                                         audience: params[:recipient_audience],
                                         include_actor: params[:include_actor].present?)

    EventBus.broadcast 'outcome_create', outcome, actor

    Events::OutcomeCreated.publish!(outcome: outcome,
                                    recipient_user_ids: users.pluck(:id),
                                    recipient_audience: params[:recipient_audience])
  end

  def self.update(outcome:, actor:, params: {})
    actor.ability.authorize! :update, outcome

    UserInviter.authorize!(user_ids: params[:recipient_user_ids],
                           emails: params[:recipient_emails],
                           audience: params[:recipient_audience],
                           model: outcome,
                           actor: actor)

    outcome.assign_attributes_and_files(params.slice(:statement, :statement_format))
    return false unless outcome.valid?
    outcome.store_calendar_invite if outcome.should_send_calendar_invite

    outcome.save!
    outcome.update_versions_count

    users = UserInviter.where_or_create!(actor: actor,
                                         emails: params[:recipient_emails],
                                         user_ids: params[:recipient_user_ids],
                                         model: outcome,
                                         audience: params[:recipient_audience],
                                         include_actor: params[:include_actor].present?)

    EventBus.broadcast 'outcome_update', outcome, actor

    byebug
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
