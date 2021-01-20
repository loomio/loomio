class API::V1::DiscussionReadersController < API::V1::RestfulController
  def index
    @discussion = load_and_authorize(:discussion)
    query = params[:query]
    instantiate_collection do |collection|
      collection = collection.where(discussion_id: @discussion.id)
      if query
        collection = collection.
          joins('LEFT OUTER JOIN users on discussion_readers.user_id = users.id').
          where("users.name ilike :first OR
                 users.name ilike :last OR
                 users.email ilike :first OR
                 users.username ilike :first",
                 first: "#{query}%", last: "% #{query}%")
      end
      collection
    end
    respond_with_collection
  end

  def make_admin
    current_user.ability.authorize! :make_admin, discussion_reader
    discussion_reader.update(admin: true)
    respond_with_resource
  end

  def remove_admin
    current_user.ability.authorize! :remove_admin, discussion_reader
    discussion_reader.update(admin: false)
    respond_with_resource
  end

  def resend
    current_user.ability.authorize! :resend, discussion_reader
    raise NotImplementedError.new
  end

  def revoke
    current_user.ability.authorize! :remove, discussion_reader
    discussion_reader.update(revoked_at: Time.zone.now)
    respond_with_resource
  end

  private

  def discussion_reader
    @discussion_reader = DiscussionReader.find(params[:id])
  end

  def default_scope
    super.merge({include_email: (@discussion_reader || @discussion).discussion.admins.exists?(current_user.id)})
  end

  def accessible_records
    DiscussionReader.includes(:user, :discussion).where(discussion_id: @discussion.id)
  end
end
