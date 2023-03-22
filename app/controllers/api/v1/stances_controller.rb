class API::V1::StancesController < API::V1::RestfulController
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
    @stance = current_user.stances.find(params[:id])
    StanceService.uncast(stance: @stance, actor: current_user)
    respond_with_resource
  end

  def index
    instantiate_collection do |collection|
      if query = params[:query]
        collection = collection.
          joins('LEFT OUTER JOIN users on stances.participant_id = users.id').
          where(latest: true, revoked_at: nil).
          where("users.name ilike :first OR
                 users.name ilike :last OR
                 users.email ilike :first OR
                 users.username ilike :first",
                 first: "#{query}%", last: "% #{query}%")
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
      self.add_meta :member_ids, @poll.group.members.pluck(:user_id) & user_ids
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
    @stance = Stance.find_by(participant_id: params[:participant_id], poll_id: params[:poll_id])
    current_user.ability.authorize! :make_admin, @stance
    @stance.update(admin: true)
    respond_with_resource
  end

  def remove_admin
    @stance = Stance.find_by(participant_id: params[:participant_id], poll_id: params[:poll_id])
    current_user.ability.authorize! :remove_admin, @stance
    @stance.update(admin: false)
    @stance.poll.update_counts!
    respond_with_resource
  end

  def revoke
    @stance = Stance.find_by(participant_id: params[:participant_id], poll_id: params[:poll_id])
    current_user.ability.authorize! :remove, @stance
    @stance.update(revoked_at: Time.zone.now, revoker_id: current_user.id)
    @stance.poll.update_counts!
    respond_with_resource
  end

  private

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
