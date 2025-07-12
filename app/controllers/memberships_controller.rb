class MembershipsController < ApplicationController
  include PrettyUrlHelper

  def join
    group = Group.published.find_by!(token: params.require(:token))
    session[:pending_group_token] = group.token
    redirect_to params[:back_to] || polymorphic_path(group)
  end

  def show
    session[:pending_membership_token] = membership.token
    redirect_to params[:back_to] || polymorphic_path(Group.find_by(id: membership.group_id))
  rescue ActiveRecord::RecordNotFound
    redirect_to join_url(Group.find_by!(token: params[:token]))
  end

  def consume
    head :ok
  end

  private

  def membership
    @membership ||= Membership.find_by!(token: params[:token])
  end
end
