class API::StancesController < API::RestfulController
  include UsesDiscussionReaders

  alias :update :create

  def my_stances
    @votes = current_user.stances.where(latest: true).includes({poll: :discussion}, :user)
    @votes = @votes.where('polls.discussion_id': @discussion.id) if load_and_authorize(:discussion, optional: true)
    @votes = @votes.where('discussions.group_id': @group.id)     if load_and_authorize(:group, optional: true)
    respond_with_collection
  end

  private

  def accessible_records
    load_and_authorize(:poll).stances.where(recent: true).order(:created_at)
  end

end
