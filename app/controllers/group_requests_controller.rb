class GroupRequestsController < BaseController
  before_filter :authenticate_user!, except: [:new, :create, :confirmation]

  def new
    @group_request = GroupRequest.new
  end

  def create
    GroupRequest.create!(params[:group_request])
    redirect_to group_request_confirmation_url
  end

  def confirmation
  end
end
