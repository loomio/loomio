module Boot
  class User
    attr_reader :user

    def initialize(user, root_url:, identity: {}, flash: {}, context_group: nil)
      @user     = user
      @root_url = root_url
      @identity = identity
      @flash    = flash.to_h
      @context_group = context_group
    end

    def payload
      @payload ||= group_payload.merge(user_payload).merge(
        current_user_id:  user.id,
        pending_identity: @identity,
        flash:            @flash,
        root_url:         @root_url
      )
    end

    def groups
      @groups ||= GroupDirectory.new(user: user, context_group: @context_group) if user.is_logged_in?
    end

    private

    def group_payload
      groups ? groups.payload.merge(groups_loaded: true) : {}
    end

    def user_payload
      ActiveModel::ArraySerializer.new(Array(@user),
        each_serializer: CurrentUserSerializer,
        root: :users
      ).as_json
    end
  end
end
