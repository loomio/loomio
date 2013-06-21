class GroupRequestsController < BaseController
  before_filter :authenticate_user!, except: [:verify, :new, :create, :confirmation]
  before_filter :already_verified, only: :verify

  def new
    @group_request = GroupRequest.new
  end

  def create
    @group_request = GroupRequest.new(params[:group_request])
    if @group_request.save
      StartGroupMailer.verification(@group_request).deliver
      redirect_to group_request_confirmation_url
    else
      render action: 'new'
    end
  end

  def verify
    group_request.verify!
  end

  def confirmation
  end


  private

  def group_request
    return @group_request if @group_request
    @group_request = GroupRequest.find_by_token(params[:token])
  end

  def already_verified
    render 'application/display_error', locals: { message: t('error.group_request_already_verified') } if group_request.verified?
  end
end
