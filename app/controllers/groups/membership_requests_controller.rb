class Groups::MembershipRequestsController < BaseController
  before_filter :load_group, except:[:cancel]
  before_filter :authenticate_user!, except: [:new, :create, :cancel]
  load_and_authorize_resource :membership_request, only: :cancel, parent: false


  def new
    @membership_request = MembershipRequest.new
    @membership_request.group = @group
    @membership_request.requestor = current_user
    authorize! :create, @membership_request
  end

  def create
    build_membership_request
    authorize! :create, @membership_request
    if @membership_request.save
      flash[:success] = t(:'success.membership_requested')
      Events::MembershipRequested.publish!(@membership_request)
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

  def build_membership_request
    @membership_request = MembershipRequest.new params[:membership_request]
    @membership_request.group = @group
    @membership_request.requestor = current_user if user_signed_in?
  end
end
