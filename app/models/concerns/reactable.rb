module Reactable
  def self.included(base)
    base.has_many :reactions, -> { joins(:users).where("users.deactivated_at": nil) }, dependent: :destroy
    base.has_many :reactors, through: :reactions, source: :user
  end
end
