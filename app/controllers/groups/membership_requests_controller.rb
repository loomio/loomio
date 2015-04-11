class Groups::MembershipRequestsController < BaseController
  skip_before_filter :authenticate_user!, except: :cancel
  before_filter :load_group, except: :cancel
  before_filter :build_membership_request, except: [:cancel]
  load_and_authorize_resource :membership_request, only: :cancel

  def new
    store_previous_location
  end

  def create
    if MembershipRequestService.create(membership_request: @membership_request, actor: current_user_or_visitor)
      flash[:success] = t(:'success.membership_requested', which_group: @group.full_name)
      redirect_to after_request_membership_path
    else
      if @membership_request.errors[:requestor].present?
        flash[:alert] = @membership_request.errors.values.first
      end
      render :new
    end
  end

  def cancel
    @membership_request.destroy
    flash[:success] = t(:'notice.membership_request_canceled')
    redirect_to @membership_request.group
  end

  private

  def load_group
    @group = Group.find_by_key!(params[:group_id])
  end

  def build_membership_request
    args = {group: @group, requestor: current_user}
    if params[:membership_request].present?
      args.merge! permitted_params.membership_request
    end
    @membership_request = MembershipRequest.new(args)
  end

  def after_request_membership_path
    path = session['user_return_to'] || group_path(@group)
    clear_stored_location
    path
  end
end
