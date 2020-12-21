class API::StancesController < API::RestfulController
  def index
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
      collection
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
    current_user.ability.authorize! :make_admin, stance
    stance.update(admin: true)
    respond_with_resource
  end

  def remove_admin
    current_user.ability.authorize! :remove_admin, stance
    stance.update(admin: false)
    respond_with_resource
  end

  def revoke
    current_user.ability.authorize! :remove, stance
    stance.update(revoked_at: Time.zone.now)
    respond_with_resource
  end

  private
  def stance
    @stance = Stance.find_by(participant_id: params[:participant_id], poll_id: params[:poll_id])
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

  def valid_orders
    [
      'cast_at DESC NULLS LAST', # lastest stances
      'cast_at DESC NULLS FIRST' # undecided first
    ]
  end
end
