module DiscardableBy
  extend ActiveSupport::Concern

  included do
    include Discard::Model
    prepend ActorMethods
  end

  module ActorMethods
    def discard!(actor: nil, at: Time.current)
      update!(discarded_at: at, discarded_by: actor&.id)
    end

    def undiscard!
      update!(discarded_at: nil, discarded_by: nil)
    end
  end
end
