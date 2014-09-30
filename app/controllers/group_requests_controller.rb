class GroupRequestsController < BaseController
  skip_before_filter :authenticate_user!

  def create
    @group_request = GroupRequest.new(permitted_params.group_request)
    if @group_request.save
      SetupGroup.from_group_request(@group_request)
      redirect_to confirmation_group_requests_url
    else
      render :new
    end
  end

  def confirmation
  end

  def new
    build_group_request
    @group_request.payment_plan = 'undetermined'
  end

  private

  def using_commercial_page?
    ENV['SHOW_PAYMENT_PAGE'].present?
  end
  helper_method :using_commercial_page?

  def build_group_request
    @group_request = GroupRequest.new
    if user_signed_in?
      @group_request.admin_name = current_user.name
      @group_request.admin_email = current_user.email
    end
  end

end
