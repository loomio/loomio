class MembershipsController < ApplicationController
  include PrettyUrlHelper

  rescue_from Membership::InvitationAlreadyUsed do
    redirect_to membership.group
  end

  def show
    if current_user.is_logged_in?
      MembershipService.redeem(membership, current_user)
      session.delete(:pending_invitation_id)
    else
      session[:pending_invitation_id] = params[:id]
    end

    if back_to_param.match(/^http[s]?:\/\/#{ENV['CANONICAL_HOST']}/)
      redirect_to back_to_param
    else
      redirect_to polymorphic_url(membership.target_model, membership_token: membership.token)
    end
  end

  private

  def membership
    @membership ||= Membership.find_by_token!(params[:id])
  end

  def back_to_param
    @back_to_param ||= URI.unescape params[:back_to].to_s
  end
end
