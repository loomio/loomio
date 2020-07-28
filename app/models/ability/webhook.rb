module Ability::Webhook
  def initialize(user)
    super(user)

    can [:create, :destroy, :update], ::Webhook do |webhook|
      webhook.group.admins.exists?(user.id)
    end
  end
end
