class MembershipsController < ApplicationController
  include PrettyUrlHelper

  def join
    session[:pending_group_token] = join_target.guest_group.token
    redirect_to back_to_url || polymorphic_url(join_target)
  end

  def show
    session[:pending_membership_token] = membership.token
    redirect_to back_to_url || polymorphic_url(membership.target_model)
  rescue ActiveRecord::RecordNotFound
    redirect_to join_url(Group.find_by!(token: params[:token]))
  end

  private

  def membership
    @membership ||= Membership.find_by!(token: params[:token])
  end

  def join_target
    @join_target ||= params
      .require(:model)
      .classify.constantize
      .find_by!(token: params.require(:token))
  end

  def back_to_url
    @back_to_url ||= begin
      url = URI.unescape params[:back_to].to_s
      url if url.match(/^http[s]?:\/\/#{ENV['CANONICAL_HOST']}/)
    end
  end
end
