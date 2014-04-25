class Groups::ManageMembershipRequestsController < GroupBaseController
  load_and_authorize_resource :membership_request, only: [:approve, :ignore], parent: false
  before_filter :load_group_and_check_for_response, only: [:approve, :ignore]

  def index
    @group = GroupDecorator.new Group.find(params[:group_id])
    if can? :manage_membership_requests, @group
      @current_requests  = @group.membership_requests.pending
      @previous_requests = @group.membership_requests.responded_to.page(params[:page]).per(7)

      render 'index'
    else
      redirect_to group_path(@group)
      flash[:warning] = t(:'error.access_denied')
    end
  end

  def approve
    ManageMembershipRequests.approve!(@membership_request, approved_by: current_user)
    set_request_approved_flash_message
    redirect_to group_membership_requests_path(@group)
  end

  def ignore
    ManageMembershipRequests.ignore!(@membership_request, ignored_by: current_user)
    flash[:success] = t(:'notice.membership_request_ignored')
    redirect_to group_membership_requests_path(@group)
  end

  private

  def load_group_and_check_for_response
    @group = @membership_request.group
    response = @membership_request.response
    unless response.nil?
      if response == 'approved'
        flash[:warning] = t(:'warning.membership_request_already_approved')
      elsif response == 'ignored'
        flash[:warning] = t(:'warning.membership_request_already_ignored')
      end
      redirect_to group_membership_requests_path(@group)
    end
  end

  def set_request_approved_flash_message
    if @membership_request.from_a_visitor?
      flash[:success] = t(:'notice.membership_approved')+ ' ' +  t(:'notice.new_user_added', user_email_or_name: @membership_request.name)
    else
      flash[:success] = t(:'notice.membership_approved')+ ' ' + t(:'notice.user_added', user_email_or_name: @membership_request.name)
    end
  end
end
