class DiscussionsController < BaseController
  def add_comment
    if resource.can_add_comment? current_user
      comment = resource.add_comment(current_user, "Hey guys this is my comment!" )
    end
    redirect_to group_url(resource.group)
  end
end
