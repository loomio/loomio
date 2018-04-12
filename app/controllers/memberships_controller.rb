class MembershipsController < ApplicationController
  include PrettyUrlHelper

  rescue_from Membership::InvitationAlreadyUsed do
    redirect_to membership.group
  end

  def join
    membership = Membership.new(user: current_user, group: group_to_join)
    if current_user.is_logged_in?
      service.create(membership: membership, actor: current_user)
    else
      session[:pending_group_token] = params.require(:token)
    end

    redirect_to target_url(membership)
  end

  def show
    @membership = Membership.find_by_token!(params[:id])
    if current_user.is_logged_in?
      MembershipService.redeem(@membership, current_user)
      session.delete(:pending_invitation_id)
    else
      session[:pending_invitation_id] = params[:id]
    end
    target_url
  end

  private
  def target_url
    if back_to_param.match(/^http[s]?:\/\/#{ENV['CANONICAL_HOST']}/)
      back_to_param
    else
      polymorphic_url(@membership.target_model, membership_token: @membership.token)
    end
  end

  def group_to_join
    resource_class.find_by!(token: params.require(:token)).guest_group
  end

  def resource_class
    params.require(:model).classify.constantize
  end

  def back_to_param
    @back_to_param ||= URI.unescape params[:back_to].to_s
  end
end
