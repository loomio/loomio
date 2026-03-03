class Reaction < ApplicationRecord
  belongs_to :reactable, polymorphic: true
  belongs_to :user

  # TODO: ensure one reaction per reactable
  # validates_uniqueness_of :user_id, scope: :reactable
  validates_presence_of :user, :reactable

  delegate :group, to: :reactable, allow_nil: true
  delegate :group_id, to: :reactable, allow_nil: true
  delegate :members, to: :reactable, allow_nil: true
  delegate :title_model, to: :reactable

  alias :author :user

  def author_id
    user_id
  end


end
