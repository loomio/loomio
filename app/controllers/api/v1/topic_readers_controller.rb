class Api::V1::TopicReadersController < Api::V1::RestfulController
  def index
    @topic = load_and_authorize(:topic)
    query = params[:query]
    instantiate_collection do |collection|
      collection = collection.where(topic_id: @topic.id)
      if query
        collection = collection.
          joins('LEFT OUTER JOIN users on topic_readers.user_id = users.id').
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
    current_user.ability.authorize! :make_admin, topic_reader
    topic_reader.update(admin: true)
    respond_with_resource
  end

  def remove_admin
    current_user.ability.authorize! :remove_admin, topic_reader
    topic_reader.update(admin: false)
    respond_with_resource
  end

  def resend
    current_user.ability.authorize! :resend, topic_reader
    raise NotImplementedError.new
  end

  def revoke
    current_user.ability.authorize! :remove, topic_reader
    topic_reader.update(revoked_at: Time.zone.now, revoker_id: current_user.id)
    respond_with_resource
  end

  private

  def topic_reader
    @topic_reader = TopicReader.find(params[:id])
  end

  def default_scope
    topic = @topic || @topic_reader&.topic
    is_admin = topic ? topic.admins.exists?(current_user.id) : false
    super.merge({include_email: is_admin})
  end

  def accessible_records
    TopicReader.includes(:user, :topic).where(topic_id: @topic.id)
  end
end
