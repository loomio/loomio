class DiscussionsRedirectController < GroupBaseController
  BLOCK_ID_GREATER_THAN = 10000

  before_filter :reject_new_ids
  before_filter :load_resource_from_id

  def show
    redirect_to discussion_path(@discussion)
  end

  private

    def reject_new_ids
      if params[:id].to_i > BLOCK_ID_GREATER_THAN
        flash[:error] = "use keys to access records with id greater than > #{BLOCK_ID_GREATER_THAN}"
        redirect_to root_path
      end
    end

    def load_resource_from_id
      @discussion = Discussion.find(params[:id])
    end

end
