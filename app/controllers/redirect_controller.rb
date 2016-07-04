class RedirectController < ApplicationController
  skip_before_filter :set_application_locale

  def group_subdomain
    moved_to group_url(Group.find_by!(subdomain: request.subdomain), default_subdomain)
  end

  def group_key
    moved_to group_url(Group.find_by_key!(params[:id]), default_subdomain)
  end

  def discussion_key
    moved_to discussion_url(Discussion.find_by_key!(params[:id]), default_subdomain)
  end

  def motion_key
    moved_to motion_url(Motion.find_by_key!(params[:id]), default_subdomain)
  end

  def group_id
    not_found_if_greater_than(11500)
    moved_to group_url(Group.find_by_id!(params[:id]), default_subdomain)
  end

  def discussion_id
    not_found_if_greater_than(11500)
    moved_to discussion_url(Discussion.find_by_id!(params[:id]), default_subdomain)
  end

  def motion_id
    not_found_if_greater_than(7300)
    moved_to motion_url(Motion.find_by_id!(params[:id]), default_subdomain)
  end

  private
  def not_found_if_greater_than(max)
     raise ActionController::RoutingError.new('Not Found') if params[:id].to_i > max
  end

  def default_subdomain
    { subdomain: ENV['DEFAULT_SUBDOMAIN'] }
  end

  def moved_to(url)
    redirect_to url, status: :moved_permanently
  end
end
