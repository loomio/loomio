class MembershipsController < ApplicationController
  include PrettyUrlHelper

  def join
    group = FormalGroup.published.find_by!(token: params.require(:token))
    session[:pending_group_token] = group.token
    redirect_to back_to_url || polymorphic_url(group)
  end

  def show
    session[:pending_membership_token] = membership.token
    redirect_to back_to_url || polymorphic_url(membership.group)
  rescue ActiveRecord::RecordNotFound
    redirect_to join_url(Group.find_by!(token: params[:token]))
  end

  private

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
