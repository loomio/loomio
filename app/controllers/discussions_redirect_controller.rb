class DiscussionsRedirectController < GroupBaseController
  # include DiscussionsHelper
  before_filter :load_discussion_from_id, except: []

  def show
    redirect_to discussion_path(@discussion)
  end

  private

    def load_discussion_from_id
      @discussion = Discussion.find_by(params[:id])
    end

end