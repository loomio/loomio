class GroupRequestsController < BaseController
  before_filter :authenticate_user!, except: [:start, :new, :create, :confirmation]

  def new
    @group_request = GroupRequest.new
  end

  def create
    if params[:robot_trap].blank?
      @group_request = GroupRequest.new(params[:group_request])
      if @group_request.save
        redirect_to group_request_confirmation_url
      else
        render :action => "new"
      end
    end
  end

  def confirmation
  end
end
