class Stance < ActiveRecord::Base
  include HasMentions

  is_mentionable  on: :statement

  belongs_to :poll, required: true
  belongs_to :poll_option, required: true
  belongs_to :participant, polymorphic: true, required: true

  scope :latest, -> { where(latest: true) }

  def author
    participant
  end
end
