module Hideable
  extend ActiveSupport::Concern

  included do
    belongs_to :hider, class_name: "User", optional: true

    scope :visible, -> { where(hidden_at: nil) }
    scope :hidden, -> { where.not(hidden_at: nil) }
  end

  def hidden?
    hidden_at.present?
  end

  def hide!(actor: nil)
    update!(hidden_at: Time.current, hider_id: actor&.id)
  end

  def unhide!
    update!(hidden_at: nil, hider_id: nil)
  end
end
