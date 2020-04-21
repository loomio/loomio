class API::StancesController < API::RestfulController
  def my_stances
    self.collection = current_user.stances.latest.includes({poll: :discussion})
    self.collection = collection.where('polls.discussion_id': @discussion.id) if load_and_authorize(:discussion, optional: true)
    self.collection = collection.where('discussions.group_id': @group.id)     if load_and_authorize(:group, optional: true)
    respond_with_collection
  end

  private
  def accessible_records
    load_and_authorize(:poll).stances.latest.includes(:stance_choices, :participant)
  end

  def valid_orders
    [
      'cast_at DESC NULLS LAST', # lastest stances
      'cast_at DESC NULLS FIRST' # undecided first
    ]
  end
end
