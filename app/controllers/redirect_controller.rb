class RedirectController < ActionController::Base
  def group_subdomain
    moved_to group_url(Group.find_by!(subdomain: request.subdomain), subdomain: ENV['DEFAULT_SUBDOMAIN'])
  end

  def group_key
    moved_to group_url(Group.find_by_key!(params[:id]), subdomain: ENV['DEFAULT_SUBDOMAIN'])
  end

  def discussion_key
    moved_to discussion_url(Discussion.find_by_key!(params[:id]), subdomain: ENV['DEFAULT_SUBDOMAIN'])
  end

  def motion_key
    moved_to motion_url(Motion.find_by_key!(params[:id]), subdomain: ENV['DEFAULT_SUBDOMAIN'])
  end

  def group_id
    moved_to group_url(Group.where(id: params[:id]).where('id <  11500').first, subdomain: ENV['DEFAULT_SUBDOMAIN'])

  end

  def discussion_id
    moved_to discussion_url(Discussion.where(id: params[:id]).where('id < 11500').first, subdomain: ENV['DEFAULT_SUBDOMAIN'])
 
  end

  def motion_id
    moved_to motion_url(Motion.where(id: params[:id]).where('id < 7300').first, subdomain: ENV['DEFAULT_SUBDOMAIN']) 
  end

  private
  def moved_to(url)
    redirect_to url, status: :moved_permanently
  end
end
