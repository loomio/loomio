module Boot
  class User
    attr_reader :user

    def initialize(user, identity: {}, flash: {})
      @user     = user
      @identity = identity
      @flash    = flash.to_h
    end

    def payload
      @payload ||= user_payload.merge(
        current_user_id:  user.id,
        pending_identity: @identity,
        flash:            @flash
      )
    end

    private

    def user_payload
      ActiveModel::ArraySerializer.new(Array(@user),
        scope:           serializer_scope,
        each_serializer: (user.restricted ? Restricted::UserSerializer : Full::UserSerializer),
        root: :users
      ).as_json
    end

    def serializer_scope
      {
        formal_memberships: formal_memberships,
        notifications:      notifications,
        identities:         identities
      }.compact
    end

    def formal_memberships
      return nil if user.experiences['vue_client']
      @formal_memberships ||= user.memberships.formal.includes(:user, :group)
    end

    def notifications
      return nil if user.experiences['vue_client']
      @notifications ||= NotificationCollection.new(user).notifications unless user.restricted
    end

    def identities
      @identities ||= user.identities.order(created_at: :desc) unless user.restricted
    end
  end
end
