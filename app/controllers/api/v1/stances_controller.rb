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

  def latest_stance_topic_items
    stances = Stance.where(
      participant_id: current_user.id,
      poll_id: resource.poll_id
    ).order(id: :desc).limit(5)
    TopicItem.where(itemable: stances).order(id: :desc).limit(5)
  end

  def update_response
    if resource.errors.empty?
      topic_items = latest_stance_topic_items
      if topic_items.any?
        render json: topic_items,
               scope: default_scope,
               each_serializer: TopicItemSerializer,
               root: :topic_items,
               meta: meta.merge(root: :topic_items)
      else
        respond_with_resource
      end
    else
      respond_with_errors
    end
  end

  def uncast
    @stance = current_user.stances.latest.find(params[:id])
    StanceService.uncast(stance: @stance, actor: current_user)
    respond_with_recent_stances
  end

  def set_weight
    self.resource = Stance.latest.find(params[:id])
    StanceService.set_weight stance: resource, weight: params.require(:weight), actor: current_user
    respond_with_resource
  end

  def reset_weights
    mode = params[:mode] || 'value'
    weight = params.require(:weight) if mode == 'value'
    StanceService.reset_weights(poll: Poll.find(params.require(:poll_id)), mode: mode, weight: weight, actor: current_user)
    render json: {updated: true}
  end

  def redact
    load_resource
    StanceService.redact(stance: resource, actor: current_user)
    respond_with_resource
  end

  def unredact
    load_resource
    StanceService.unredact(stance: resource, actor: current_user)
    respond_with_resource
  end

  def index
    instantiate_collection do |collection|
      if name = params[:name].presence
        collection = collection.
          joins('LEFT OUTER JOIN users on stances.participant_id = users.id').
          where(latest: true, revoked_at: nil).
          where("users.name ilike :first OR
                 users.name ilike :last OR
                 users.email ilike :first OR
                 users.username ilike :first",
                 first: "#{name}%", last: "% #{name}%")
      end

      case params[:stance_filter]
      when 'cast'
        collection = collection.decided
      when 'uncast'
        collection = collection.undecided
      end

      if @poll.results_available?
        if poll_option_id = params[:poll_option_id].presence
          collection = collection.joins(:poll_options).where("poll_options.id" => poll_option_id)
        end
      else
        collection = collection.where(participant_id: current_user.id)
      end

      collection.order('cast_at DESC NULLS LAST, created_at DESC')
    end
    add_voter_details_meta if !@poll.anonymous?
    respond_with_collection
  end

  def users
    poll = load_and_authorize(:poll)
    current_user.ability.authorize!(:add_voters, poll)
    voters = if poll.detached_anonymous?
      User.where(id: poll.anonymous_poll_voters.select(:voter_id))
    else
      User.where(id: poll.stances.latest.select(:participant_id))
    end
    if query = params[:query].presence
      voters = voters.where(
        "users.name ILIKE :first OR users.name ILIKE :last OR users.email ILIKE :first OR users.username ILIKE :first",
        first: "#{query}%", last: "% #{query}%"
      )
    end

    self.collection_count = voters.count
    # Sort by the original voter record so later vote revisions do not move a voter to the top.
    added_order = if poll.detached_anonymous?
      "(SELECT anonymous_poll_voters.id FROM anonymous_poll_voters WHERE anonymous_poll_voters.poll_id = #{poll.id} AND anonymous_poll_voters.voter_id = users.id) DESC"
    else
      "(SELECT MIN(stances.id) FROM stances WHERE stances.poll_id = #{poll.id} AND stances.participant_id = users.id) DESC"
    end
    self.collection = page_collection(voters.order(Arel.sql(added_order)))
    add_voter_role_meta(collection.ids)
    respond_with_collection serializer: AuthorSerializer, root: :users
  end

  def my_stances
    self.collection = current_user.stances.latest.includes({poll: :topic})
                        .where(cast_at: nil)
                        .joins(:poll)
                        .where('polls.closed_at IS NULL')
                        .where('polls.discarded_at IS NULL')
                        .where.not('polls.closing_at': nil)
                        .where.not('polls.opened_at': nil)
    self.collection = collection.where('polls.topic_id': @discussion.topic_id) if load_and_authorize(:discussion, optional: true)
    self.collection = collection.joins(poll: :topic).where('topics.group_id': @group.id) if load_and_authorize(:group, optional: true)
    respond_with_collection
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

  def add_voter_details_meta
    # These fields were previously available through receipts, which excludes
    # public readers and can be restricted to poll administrators.
    can_view_details = @poll.group_id && if AppConfig.app_features[:verify_participants_admin_only]
      @poll.admins.exists?(current_user.id)
    else
      @poll.members.exists?(current_user.id) || @poll.stances.latest.exists?(participant_id: current_user.id)
    end
    add_meta :show_voter_details, !!can_view_details
    return unless can_view_details

    stances = collection.to_a
    voter_ids = stances.map(&:participant_id)
    memberships = @poll.group.present? ? @poll.group.memberships.where(user_id: voter_ids).index_by(&:user_id) : {}
    inviters = User.where(id: stances.map(&:inviter_id).compact).index_by(&:id)
    show_voter_email = @poll.group.admins.include?(current_user)
    voters = show_voter_email ? User.where(id: voter_ids).index_by(&:id) : {}

    add_meta :show_voter_email, show_voter_email
    details_by_user_id = stances.map do |stance|
      details = {
        member_since: memberships[stance.participant_id]&.accepted_at&.to_date&.iso8601,
        inviter_name: inviters[stance.inviter_id]&.name,
        invited_on: stance.created_at&.to_date&.iso8601
      }
      details[:voter_email] = voters[stance.participant_id]&.email if show_voter_email
      [stance.participant_id, details]
    end.to_h
    add_meta :voter_details_by_user_id, details_by_user_id
  end

  def add_voter_role_meta(user_ids)
    self.add_meta :guest_ids, @poll.topic.topic_readers.guests.pluck(:user_id) & user_ids
    self.add_meta :group_admin_ids, @poll.group.admins.pluck(:user_id) & user_ids
    self.add_meta :topic_admin_ids, @poll.topic.topic_readers.admins.pluck(:user_id) & user_ids
    if @poll.vote_weights_active? && @poll.closed_at.nil?
      stances = @poll.stances.latest.where(participant_id: user_ids)
      self.add_meta :stance_ids_by_user_id, stances.pluck(:participant_id, :id).to_h
      self.add_meta :weights_by_user_id, stances.pluck(:participant_id, :weight).to_h
    end
  end

  def live_update_outdated_stances(poll)
    return if poll.topic.nil?

    # want to find stances with comments
    stance_ids = poll.topic.items.where(
      itemable_type: 'Stance',
      itemable_id: poll.stances.with_reason.where(latest: false).pluck(:id)
    ).where("child_count > 0").pluck('itemable_id')
    stances = Stance.where(id: stance_ids).order('id desc').limit(50)
    MessageChannelService.publish_models(stances, user_id: current_user.id)
    if poll.results_available?
      MessageChannelService.publish_models(stances, group_id: poll.group_id, topic_id: poll.topic_id)
    end
  end

  def respond_with_recent_stances
    @stances = @stance.poll.stances.where(revoked_at: nil, participant_id: current_user.id).order('id desc').limit(10)
    respond_with_collection
  end

  def current_user_is_admin?
    poll = @poll || @stance&.poll || (resource.poll if resource.respond_to?(:poll))
    return false unless poll

    poll.admins.exists?(current_user.id)
  end

  def exclude_types
    %w[group discussion]
  end

  def default_scope(records = records_to_serialize)
    super(records).merge(include_email: current_user_is_admin?)
  end

  def accessible_records
    load_and_authorize(:poll).stances.latest
  end
end
