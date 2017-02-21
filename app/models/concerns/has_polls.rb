module HasPolls
  extend ActiveSupport::Concern

  included do
    has_many :poll_references, as: :reference
    has_many :polls, through: :poll_references
  end
end
