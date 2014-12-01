class API::DiscussionsController < API::RestfulController
  load_and_authorize_resource only: :show, find_by: :key
  load_resource only: [:create, :update]

  def index
    load_and_authorize_group
    @discussions = visible_records.page(params[:page]).per(25).to_a
    respond_with_collection
  end

  def show
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

  private

  def visible_records
    if @group
      GroupDiscussionsViewer.for(user: current_user, group: @group)
    else
      Queries::VisibleDiscussions.new(user: current_user)
    end
  end
end
