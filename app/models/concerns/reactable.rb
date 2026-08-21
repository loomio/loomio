module Reactable
  def self.included(base)
    base.has_many :reactions, as: :reactable, dependent: :destroy
    base.has_many :reactors, through: :reactions, source: :user
  end
end
