class API::StancesController < API::RestfulController
  include UsesDiscussionReaders

  alias :update :create

  def my_stances
    @stances = current_user.stances.latest.includes({poll: :discussion})
    @stances = @stances.where('polls.discussion_id': @discussion.id) if load_and_authorize(:discussion, optional: true)
    @stances = @stances.where('discussions.group_id': @group.id)     if load_and_authorize(:group, optional: true)
    respond_with_collection
  end

  private

  def accessible_records
    load_and_authorize(:poll).stances.latest.order(:created_at)
  end

end
