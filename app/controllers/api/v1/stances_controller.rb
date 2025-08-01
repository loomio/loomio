class Api::V1::StancesController < Api::V1::RestfulController
  def create
    super
  rescue ActiveRecord::RecordNotUnique
    self.resource = resource_class.find_by!(
      poll_id: params[:stance][:poll_id],
      participant_id: current_user.id)
    update_action
    update_response
  end

  def uncast
    @stance = current_user.stances.latest.find(params[:id])
    StanceService.uncast(stance: @stance, actor: current_user)
    respond_with_recent_stances
  end

  def index
    instantiate_collection do |collection|
      if !@poll.anonymous && name = params[:name].presence
        collection = collection.
          joins('LEFT OUTER JOIN users on stances.participant_id = users.id').
          where(latest: true, revoked_at: nil).
          where("users.name ilike :first OR
                 users.name ilike :last OR
                 users.email ilike :first OR
                 users.username ilike :first",
                 first: "#{name}%", last: "% #{name}%")
      end

      if @poll.show_results?(voted: true)
        if poll_option_id = params[:poll_option_id].presence
          collection = collection.joins(:poll_options).where("poll_options.id" => poll_option_id)
        end
      end

      collection.order('cast_at DESC NULLS LAST, created_at DESC')
    end
    respond_with_collection
  end

  def users
    instantiate_collection do |collection|
      if query = params[:query]
        collection = collection.
          joins('LEFT OUTER JOIN users on stances.participant_id = users.id').
          where("users.name ilike :first OR
                 users.name ilike :last OR
                 users.email ilike :first OR
                 users.username ilike :first",
                 first: "#{query}%", last: "% #{query}%")
      end

      user_ids = collection.pluck(:participant_id)
      self.add_meta :guest_ids, collection.where(guest: true).pluck(:participant_id) & user_ids
      self.add_meta :member_admin_ids, @poll.group.admins.pluck(:user_id) & user_ids
      self.add_meta :stance_admin_ids, collection.where(admin: true).pluck(:participant_id) & user_ids
      User.where(id: collection.pluck(:participant_id))
    end
    respond_with_collection serializer: AuthorSerializer
  end

  def my_stances
    self.collection = current_user.stances.latest.includes({poll: :discussion})
    self.collection = collection.where('polls.discussion_id': @discussion.id) if load_and_authorize(:discussion, optional: true)
    self.collection = collection.where('discussions.group_id': @group.id)     if load_and_authorize(:group, optional: true)
    respond_with_collection
  end

  def make_admin
    @stance = Stance.latest.find_by(participant_id: params[:participant_id], poll_id: params[:poll_id])
    current_user.ability.authorize! :make_admin, @stance
    @stance.update(admin: true)
    respond_with_resource
  end

  def remove_admin
    @stance = Stance.latest.find_by(participant_id: params[:participant_id], poll_id: params[:poll_id])
    current_user.ability.authorize! :remove_admin, @stance
    @stance.update(admin: false)
    @stance.poll.update_counts!
    respond_with_resource
  end

  def revoke
    @stance = Stance.latest.find_by(participant_id: params[:participant_id], poll_id: params[:poll_id])
    current_user.ability.authorize! :remove, @stance

    # revoke all stances, not just the latest one
    Stance.where(revoked_at: nil, participant_id: params[:participant_id], poll_id: params[:poll_id]).
           update_all(revoked_at: Time.zone.now, revoker_id: current_user.id)

    @stance.reload
    @stance.poll.update_counts!

    @stances = @stance.poll.stances.where(participant_id: params[:participant_id])
    live_update_outdated_stances(@stance.poll)
    respond_with_collection
  end

  private

  def live_update_outdated_stances(poll)
    return if poll.discussion.nil?

    # want to find stances with comments
    stance_ids = poll.discussion.items.where(
      eventable_type: 'Stance',
      eventable_id: poll.stances.with_reason.where(latest: false).pluck(:id)
    ).where("child_count > 0").pluck('eventable_id')
    stances = Stance.where(id: stance_ids).order('id desc').limit(50)
    MessageChannelService.publish_models(stances, group_id: poll.group_id, user_id: current_user.id)
  end

  def respond_with_recent_stances
    @event = nil
    @stances = @stance.poll.stances.where(revoked_at: nil, participant_id: current_user.id).order('id desc').limit(10)
    respond_with_collection
  end

  def current_user_is_admin?
    stance = Stance.find_by(id: params[:id])
    poll = Poll.find_by(id: params[:poll_id])
    return false unless (stance || poll)

    (stance || poll).poll.admins.exists?(current_user.id)
  end

  def exclude_types
    %w[group discussion]
  end

  def default_scope
    super.merge({include_email: current_user_is_admin?})
  end

  def accessible_records
    load_and_authorize(:poll).stances.latest
  end
end
