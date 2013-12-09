class DiscussionsRedirectController < GroupBaseController
  before_filter :load_resource_from_id, except: []

  def show
    redirect_to discussion_path(@discussion)
  end

  private

    def load_resource_from_id
      @discussion = Discussion.find(params[:id])
    end

end
