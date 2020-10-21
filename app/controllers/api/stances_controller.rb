class API::StancesController < API::RestfulController
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

  def resend
    current_user.ability.authorize! :resend, stance
    raise NotImplementedError.new
  end

  def revoke
    current_user.ability.authorize! :remove, stance
    stance.update(revoked_at: Time.zone.now)
    respond_with_resource
  end

  private

  def stance
    @stance = Stance.find(params[:id])
  end

  def default_scope
    super.merge({include_email: @stance && @stance.poll.admins.exists?(current_user.id)})
  end

  def accessible_records
    load_and_authorize(:poll).stances.latest.includes({poll: [:poll_options]}, :stance_choices, :participant)
  end

  def valid_orders
    [
      'cast_at DESC NULLS LAST', # lastest stances
      'cast_at DESC NULLS FIRST' # undecided first
    ]
  end
end
