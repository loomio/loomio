class Groups::MembershipRequestsController < BaseController
  before_filter :load_group, except:[:cancel]
  skip_before_filter :authenticate_user!, except: :cancel
  load_and_authorize_resource :membership_request, only: :cancel, parent: false


  def new
    authorize! :request_membership, @group
    @membership_request = MembershipRequest.new
    @membership_request.group = @group
    @membership_request.requestor = current_user
    store_referer_location
  end

  def create
    authorize! :request_membership, @group
    build_membership_request

    if @membership_request.persisted?
      flash[:success] = t(:'success.membership_requested', which_group: @group.full_name)
      redirect_to after_request_membership_path
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

  def store_referer_location
    session['user_return_to'] = request.env['HTTP_REFERER']
  end

  def after_request_membership_path
    path = session['user_return_to'] || group_path(@group)
    clear_stored_location
    path
  end

  def build_membership_request
    @membership_request = RequestMembership.to_group(
                            params: permitted_params.membership_request,
                            requestor: current_user,
                            group: @group)
  end

  def load_group
    @group ||= GroupDecorator.new Group.find_by_key!(params[:group_id])
  end
end
