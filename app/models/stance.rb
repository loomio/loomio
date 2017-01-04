class Stance < ActiveRecord::Base
  include HasMentions

  is_mentionable  on: :reason

  belongs_to :poll, required: true
  belongs_to :poll_option, required: true
  belongs_to :participant, polymorphic: true, required: true

  update_counter_cache :poll, :stances_count

  scope :latest, -> { where(latest: true) }

  def author
    participant
  end
end
