class API::UsersController < API::RestfulController
  def index
    instantiate_collection do |collection|
      collection.where("users.name ilike :first OR
                        users.name ilike :subsequent OR
                        users.username ilike :first",
                        first:       "#{params[:q]}%",
                        subsequent:  "% #{params[:q]}%")
    end
    respond_with_collection
  end

  private
  def accessible_records
    resource_class.active.verified.distinct.
    joins(:memberships).where('memberships.group_id': current_user.group_ids).
    where('users.id != ?', current_user.id)
  end
end
