class Groups::MembershipRequestsController < BaseController
  before_filter :load_group, except:[:cancel]
  skip_before_filter :authenticate_user!, except: :cancel
  load_and_authorize_resource :membership_request, only: :cancel, parent: false


  def new
    authorize! :request_membership, @group
    @membership_request = MembershipRequest.new
    @membership_request.group = @group
    @membership_request.requestor = current_user
  end

  def create
    authorize! :request_membership, @group
    @membership_request = RequestMembership.
                          to_group(params: permitted_params.membership_request,
                                   requestor: current_user,
                                   group: @group)
    if @membership_request.persisted?
      flash[:success] = t(:'success.membership_requested')
      redirect_to @group
    else
      if @membership_request.errors[:requestor].any?
        flash[:warning] = @membership_request.errors[:requestor].first
        redirect_to @group
      else
        render 'new'
      end
    end
  end

  def cancel
    @membership_request.destroy
    flash[:success] = t(:'notice.membership_request_canceled')
    redirect_to @membership_request.group
  end

  private

  def load_group
    @group ||= GroupDecorator.new Group.find(params[:group_id])
  end
end
