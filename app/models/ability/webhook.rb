module Ability::Webhook
  def initialize(user)
    super(user)

    can [:create, :destroy], ::Webhook do |webhook|
      byebug
      webhook.group.admins.exists?(user.id)
    end
  end
end
