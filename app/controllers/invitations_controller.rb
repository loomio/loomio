class InvitationsController < BaseController
  before_filter :get_resources
  before_filter :authenticate_user!, :except => [:show]

  def show
    if current_user
      @invitation.add_invited_member(current_user)
      redirect_to group_url(@invitation.group_id)
    else
      @inviter = @invitation.inviter
      session[:invitation] = @invitation.token
    end
  end

  private

  def get_resources
    @group = Group.find(params[:group_id])
    @invitation = Invitation.where(:group_id => params[:group_id],
                                  :token => params[:id]).first
    unless @invitation && @invitation.active?
      redirect_to group_url(@group)
    end
  end
end
