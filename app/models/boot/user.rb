module Boot
  class User
    attr_reader :user

    def initialize(user, root_url:, identity: {}, flash: {})
      @user     = user
      @root_url = root_url
      @identity = identity
      @flash    = flash.to_h
    end

    def payload
      @payload ||= user_payload.merge(
        current_user_id:  user.id,
        pending_identity: @identity,
        flash:            @flash,
        root_url:         @root_url,
        channel_token:    user.secret_token
      )
    end

    private

    def user_payload
      ActiveModel::ArraySerializer.new(Array(@user),
        each_serializer: (user.restricted ? Restricted::UserSerializer : CurrentUserSerializer),
        root: :users
      ).as_json
    end
  end
end
