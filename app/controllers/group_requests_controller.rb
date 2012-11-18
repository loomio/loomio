class GroupRequestsController < BaseController
  before_filter :authenticate_user!, except: [:start, :new, :create, :confirmation]

  def new
    @group_request = GroupRequest.new
  end

  def create
    if params[:group_request][:robot_trap].blank?
      GroupRequest.create!(params[:group_request])
    end
    redirect_to group_request_confirmation_url
  end

  def confirmation
  end
end
