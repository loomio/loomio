class Api::V1::PollsController < Api::V1::RestfulController
  def receipts
    @poll = load_and_authorize(:poll)

    if @poll.closed_at && StanceReceipt.where(poll_id: @poll.id).exists?
      receipts = StanceReceipt.where(poll_id: @poll.id)
    else
      receipts = PollService.build_receipts(@poll).map { |h| StanceReceipt.new(h) }
    end

    is_admin = @poll.group.present? && @poll.group.admins.include?(current_user)
    memberships = @poll.group.present? ? @poll.group.members.where(user_id: receipts.map(&:voter_id)).index_by(&:user_id) : {}
    voters = User.where(id: receipts.map(&:voter_id)).index_by(&:id)
    inviters = User.where(id: receipts.map(&:inviter_id)).index_by(&:id)

    render json: {
      voters_count: @poll.voters_count,
      poll_title: @poll.title,
      receipts: receipts.map do |receipt|
        voter = voters[receipt.voter_id]
        inviter = inviters[receipt.inviter_id]
        membership = memberships[receipt.voter_id]
        {
          poll_id: @poll.id,
          voter_id: receipt.voter_id,
          voter_name: voter.name,
          voter_email: is_admin ? voter.email : (voter.email || "").split('@').last,
          member_since: membership&.accepted_at&.to_date&.iso8601,
          inviter_id: receipt.inviter_id,
          inviter_name: inviter.name,
          invited_on: receipt.invited_at&.to_date&.iso8601,
          vote_cast: receipt.vote_cast
        }
      end.shuffle
    }, root: false
  end

  def show
    self.resource = load_and_authorize(:poll)
    accept_pending_membership
    respond_with_resource
  end

  def remind
    event = service.remind(poll: load_and_authorize(:poll), actor: current_user, params: resource_params)
    render json: {count: event.recipient_user_ids.count}
  end

  def index
    instantiate_collection do |collection|
      PollQuery.filter(chain: collection, params: params).order(created_at: :desc)
    end
    respond_with_collection
  end

  def close
    @event = service.close(poll: load_resource, actor: current_user)
    respond_with_resource
  end

  def reopen
    @event = service.reopen(poll: load_resource, params: resource_params, actor: current_user)
    respond_with_resource
  end

  def discard
    load_resource
    @event = service.discard(poll: resource, actor: current_user)
    respond_with_resource
  end

  def add_to_thread
    @event = service.add_to_thread(poll: load_resource, params: params, actor: current_user)
    respond_with_resource
  end

  def voters
    load_and_authorize(:poll)
    if !@poll.anonymous
      self.collection = User.where(id: @poll.voter_ids)
    else
      self.collection = User.none
    end
      cache = RecordCache.for_collection(collection, current_user.id, exclude_types)
      respond_with_collection serializer: AuthorSerializer, root: :users, scope: {cache: cache, exclude_types: exclude_types}
  end

  private
  def create_action
    @event = service.create(**{resource_symbol => resource, actor: current_user, params: resource_params})
  end

  def accessible_records
    PollQuery.visible_to(user: current_user)
  end
end
