class Api::V1::PollsController < Api::V1::RestfulController
  # The votes page has one row shape for both voting modes. Anonymous rows
  # come only from the electorate; ballot choices are never joined to voters.
  def votes
    @poll = load_and_authorize(:poll)
    @can_view_voter_email = @poll.group_id && @poll.group.admins.include?(current_user)
    return render_identified_votes unless @poll.anonymous?

    current_user.ability.authorize!(:view_anonymous_voters, @poll)

    voters_eligible = @poll.anonymous_poll_voters
    if params[:name].present?
      voters_eligible = voters_eligible.where(voter_id: voters_matching_name.select(:id))
    end
    total = voters_eligible.count
    voters_eligible = voters_eligible.order(id: :desc).offset(votes_offset).limit(votes_limit).to_a

    can_view_email = @can_view_voter_email
    memberships = @poll.group.memberships.where(user_id: voters_eligible.map(&:voter_id)).index_by(&:user_id)
    voters = User.with_attached_uploaded_avatar.where(id: voters_eligible.map(&:voter_id)).index_by(&:id)
    inviters = User.where(id: voters_eligible.map(&:inviter_id)).index_by(&:id)
    participation_status_visible = @poll.participation_status_visible?
    render json: {
      meta: {
        total:,
        show_voter_details: true,
        show_voter_email: can_view_email,
        participation_status_visible:,
        participation_status_votes_min: Poll::PARTICIPATION_STATUS_VOTES_MIN
      },
      voters: voters_eligible.map do |eligible_voter|
        voter = voters[eligible_voter.voter_id]
        membership = memberships[eligible_voter.voter_id]
        row = {
          voter_id: eligible_voter.voter_id,
          voter_name: voter.name,
          voter_thumb_url: voter.thumb_url,
          voter_avatar_initials: voter.avatar_initials,
          member_since: membership&.accepted_at&.to_date&.iso8601,
          inviter_name: inviters[eligible_voter.inviter_id]&.name,
          invited_on: eligible_voter.invited_at&.to_date&.iso8601
        }
        row[:voter_email] = voter.email if can_view_email
        row[:vote_cast] = eligible_voter.ballot_submitted if participation_status_visible
        row
      end
    }, root: false
  end

  def legacy_vote_reasons
    poll = load_and_authorize(:poll)
    raise ActiveRecord::RecordNotFound unless poll.closed? && poll.detached_anonymous? && poll.legacy_anonymous_vote_reasons.exists?

    reasons = poll.legacy_anonymous_vote_reasons
                  .joins(:anonymous_ballot)
                  .includes(anonymous_ballot: :anonymous_ballot_choices)
                  .order("anonymous_ballots.id")

    render json: reasons.map { |reason|
      ballot = reason.anonymous_ballot
      {
        body: reason.body,
        none_of_the_above: ballot.none_of_the_above?,
        choices: ballot.anonymous_ballot_choices.sort_by(&:poll_option_id).map { |choice|
          {
            poll_option_id: choice.poll_option_id,
            score: choice.score
          }
        }
      }
    }, root: false
  end

  def show
    self.resource = load_and_authorize(:poll)
    accept_pending_membership
    respond_with_resource
  end

  def remind
    notification = service.remind(poll: load_and_authorize(:poll), actor: current_user, params: resource_params)
    render json: {count: notification.recipient_user_ids.count}
  end

  def index
    instantiate_collection do |collection|
      PollQuery.filter(chain: collection, params: params).order(created_at: :desc)
    end
    respond_with_collection
  end

  def close
    service.close(poll: load_resource, actor: current_user) { |topic_item| @topic_item = topic_item }
    respond_with_resource
  end

  def reopen
    service.reopen(poll: load_resource, params: resource_params, actor: current_user) { |topic_item| @topic_item = topic_item }
    respond_with_resource
  end

  def discard
    load_resource
    service.discard(poll: resource, actor: current_user) { |topic_item| @topic_item = topic_item }
    respond_with_resource
  end

  def voters
    load_and_authorize(:poll)
    if !@poll.anonymous
      self.collection = User.with_attached_uploaded_avatar.where(id: @poll.voter_ids)
    else
      self.collection = User.none
    end
      cache = RecordCache.for_collection(collection, current_user.id, exclude_types)
      respond_with_collection serializer: AuthorSerializer, root: :users, scope: {cache: cache, exclude_types: exclude_types}
  end

  def create
    self.resource = service.create(params: resource_params, actor: current_user)
    respond_with_resource
  end

  private

  def votes_offset
    [params[:from].to_i, 0].max
  end

  def votes_limit
    (params[:per] || 50).to_i.clamp(1, 50)
  end

  def voters_matching_name
    @can_view_voter_email ? User.invitable_search(params[:name]) : User.mention_search(params[:name])
  end

  # Filter and page stances before loading voter details. Choice-based filters
  # and choice scores become available only when this viewer can see results.
  def render_identified_votes
    show_results = @poll.results_visible?(voted: @poll.stances.latest.decided.exists?(participant_id: current_user.id))
    stances = @poll.stances.latest.where(revoked_at: nil)
    if params[:name].present?
      stances = stances.where(participant_id: voters_matching_name.select(:id))
    end
    stances = stances.decided if params[:stance_filter] == 'cast'
    stances = stances.undecided if params[:stance_filter] == 'uncast'
    if show_results
      stances = stances.joins(:poll_options).where(poll_options: {id: params[:poll_option_id]}) if params[:poll_option_id].present?
    elsif !@poll.results_available?
      stances = stances.where(participant_id: current_user.id)
    end

    total = stances.count
    stances = stances.order('cast_at DESC NULLS LAST, created_at DESC').offset(votes_offset).limit(votes_limit).to_a
    voter_ids = stances.map(&:participant_id)
    voters = User.with_attached_uploaded_avatar.where(id: voter_ids).index_by(&:id)
    show_voter_details = @poll.group_id && (@poll.members.exists?(current_user.id) || @poll.stances.latest.exists?(participant_id: current_user.id))
    show_voter_email = show_voter_details && @can_view_voter_email
    memberships = show_voter_details ? @poll.group.memberships.where(user_id: voter_ids).index_by(&:user_id) : {}
    inviters = show_voter_details ? User.where(id: stances.map(&:inviter_id).compact).index_by(&:id) : {}
    render json: {
      meta: {total:, show_voter_details: !!show_voter_details, show_voter_email: !!show_voter_email},
      voters: stances.map do |stance|
        voter = voters.fetch(stance.participant_id)
        row = {
          voter_id: voter.id,
          voter_name: voter.name,
          voter_thumb_url: voter.thumb_url,
          voter_avatar_initials: voter.avatar_initials,
          vote_cast: stance.cast_at.present?
        }
        if show_voter_details
          row[:member_since] = memberships[voter.id]&.accepted_at&.to_date&.iso8601
          row[:inviter_name] = inviters[stance.inviter_id]&.name
          row[:invited_on] = stance.created_at&.to_date&.iso8601
          row[:voter_email] = voter.email if show_voter_email
        end
        if show_results && stance.cast_at.present?
          row[:option_scores] = stance.option_scores
        end
        row[:weight] = VoteWeight.format(stance.weight) if @poll.vote_weights_enabled?
        row
      end
    }, root: false
  end

  def accessible_records
    PollQuery.relevant_to(user: current_user, group_ids: poll_group_ids)
  end

  def poll_group_ids
    return [] if params[:group_key].blank?
    return [] unless group = Group.find_by(key: params[:group_key])

    (params[:subgroups] == "none") ? [group.id] : group.id_and_subgroup_ids
  end
end
