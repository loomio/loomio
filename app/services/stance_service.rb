class StanceService
  def self.invite(poll:, params:, actor:)
    actor.ability.authorize! :invite, poll

    users = UserInviter.where_or_create!(inviter: actor,
                                         emails: params[:emails],
                                         user_ids: params[:user_ids])

    result = Stance.import(users.map do |user|
      Stance.new(participant_id: user.id, poll_id: poll.id)
    end)

    stances = Stance.where(id: result.ids.map(&:to_i))

    Events::AnnouncementCreated.publish! poll, actor, stances, 'poll_announced'
    stances
  end

  def self.destroy(stance:, actor:)
    actor.ability.authorize! :destroy, stance
    stance.destroy
    EventBus.broadcast 'stance_destroy', stance, actor
  end

  def self.create(stance:, actor:)
    actor.ability.authorize! :create, stance

    actor = actor.create_user if !actor.is_logged_in?

    stance.assign_attributes(participant: actor)
    return false unless stance.valid?

    stance.poll.stances.where(participant: actor).update_all(latest: false)
    stance.save!
    stance.participant.save!
    EventBus.broadcast 'stance_create', stance, actor
    Events::StanceCreated.publish! stance
  end

  def self.update(stance:, actor:, params:)
    actor.ability.authorize! :update, stance
    HasRichText.assign_attributes_and_update_files(stance, params)
    return false unless stance.valid?
    stance.save!

    EventBus.broadcast 'stance_update', stance, actor
  end
end
