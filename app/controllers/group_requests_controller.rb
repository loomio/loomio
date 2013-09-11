class GroupRequestsController < BaseController
  skip_before_filter :authenticate_user!

  def create
    @group_request = GroupRequest.new(permitted_params.group_request)
    if @group_request.save
      SetupGroup.from_group_request(@group_request)
      redirect_to confirmation_group_requests_url(plan: @group_request.payment_plan)
    else
      if @group_request.payment_plan == 'subscription'
        render 'subscription'
      else
        render 'pwyc'
      end
    end
  end

  def confirmation
  end

  def selection
  end

  def subscription
    build_group_request
    @group_request.payment_plan = 'subscription'
  end

  def pwyc
    build_group_request
    @group_request.payment_plan = 'pwyc'
  end

  private

  def build_group_request
    @group_request = GroupRequest.new
    if user_signed_in?
      @group_request.admin_name = current_user.name
      @group_request.admin_email = current_user.email
    end
  end

end
