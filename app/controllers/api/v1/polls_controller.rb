class Api::V1::PollsController < Api::V1::RestfulController
  def receipts
    @poll = load_and_authorize(:poll)
    is_admin = @poll.group.present? && @poll.group.admins.include?(current_user)

    if @poll.closed_at
      receipts = StanceReceipt.where(poll_id: @poll.id)
    else
      receipts = PollService.generate_receipts(poll: @poll).map { |h| StanceReceipt.new(h) }
    end

    data = receipts.map do |receipt|
      membership = receipt.voter.memberships.find_by(group_id: @poll.group_id)
      val = {
        poll_id: @poll.id,
        voter_id: receipt.voter_id,
        voter_name: receipt.voter.name,
        voter_email: receipt.voter.email,
        voter_email_domain: receipt.voter.email.split('@').last,
        member_since: membership&.accepted_at&.to_date&.iso8601,
        inviter_id: receipt.inviter_id,
        inviter_name: receipt.inviter.name,
        invited_on: receipt.invited_at.to_date.iso8601,
        vote_cast: receipt.vote_cast
      }
      val.delete(:voter_email) unless is_admin
      val
    end
    render json: {
      poll_title: @poll.title,
      receipts: data.shuffle
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
