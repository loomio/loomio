module Reactable
  def self.included(base)
    base.has_many :reactions, -> { joins(:user).where("users.deactivated_at": nil) }, dependent: :destroy, as: :reactable
    base.has_many :reactors, through: :reactions, source: :user
  end
end
