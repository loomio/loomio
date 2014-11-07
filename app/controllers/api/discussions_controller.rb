class API::DiscussionsController < API::RestfulController
  load_and_authorize_resource only: :show, find_by: :key
  load_resource only: [:create, :update]

  def show
    respond_with_resource
  end

  def create
    DiscussionService.create discussion: @discussion,
                             actor: current_user
    respond_with_resource
  end

  def update
    DiscussionService.update discussion: @discussion,
                             params: discussion_params,
                             actor: current_user
    respond_with_resource
  end

  private
  def discussion_params
    params.require(:discussion).permit([:title,
                                        :description,
                                        :uses_markdown,
                                        :group_id,
                                        :private,
                                        :iframe_src])
  end

  #private

  #def visible_records
    #if @group
      #GroupDiscussionsViewer.for(user: current_user, group: @group)
    #else
      #Queries::VisibleDiscussions.new(user: current_user)
    #end
  #end
end
