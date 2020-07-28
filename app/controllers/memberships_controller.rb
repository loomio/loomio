class MembershipsController < ApplicationController
  include PrettyUrlHelper

  def join
    group = Group.published.find_by!(token: params.require(:token))
    session[:pending_group_token] = group.token
    redirect_to back_to_url || polymorphic_url(group)
  end

  def show
    session[:pending_membership_token] = membership.token
    redirect_to back_to_url || polymorphic_url(target_for(membership))
  rescue ActiveRecord::RecordNotFound
    redirect_to join_url(Group.find_by!(token: params[:token]))
  end

  private

  def target_for(membership)
    group_id = membership.group_id
    Group.find_by(id: group_id) ||
    Discussion.find_by(guest_group_id: group_id) ||
    Poll.find_by(guest_group_id: group_id)
  end

  def membership
    @membership ||= Membership.find_by!(token: params[:token])
  end

  def back_to_url
    @back_to_url ||= begin
      url = URI.unescape params[:back_to].to_s
      url if url.match(/^http[s]?:\/\/#{ENV['CANONICAL_HOST']}/)
    end
  end
end
