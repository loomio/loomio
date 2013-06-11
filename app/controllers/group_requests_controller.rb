class GroupRequestsController < BaseController
  before_filter :authenticate_user!, except: [:verify, :start_new_group, :new, :create, :confirmation]
  before_filter :already_verified, only: :verify
  before_filter :validate_token, :already_accepted, only: :start_new_group

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

  def start_new_group
    session[:start_new_group_token] = group_request.token
    redirect_to group_url(group_request.group) if user_signed_in?
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

  def already_accepted
    render 'application/display_error', locals: { message: t('error.group_request_already_accepted') } if group_request.accepted?
  end

  def validate_token
    render 'application/display_error', locals: { message: t('error.group_request_invalid_token') } unless group_request
  end
end
