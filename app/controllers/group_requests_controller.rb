class GroupRequestsController < BaseController
  before_filter :authenticate_user!, except: [:start, :start_new_group, :new, :create, :confirmation]

  def new
    @group_request = GroupRequest.new
  end

  def create
    @group_request = GroupRequest.new(params[:group_request])
    if @group_request.save
      redirect_to group_request_confirmation_url
    else
      render :action => "new"
    end
  end

  def confirmation
  end

  def start_new_group
    group_request = GroupRequest.find_by_token(params[:token])
    if group_request.nil? or group_request.accepted?
      render "invitation_accepted_error_page"
    else
      session[:start_new_group_token] = group_request.token
      redirect_to group_url(group_request.group_id) if user_signed_in?
    end
  end
end
