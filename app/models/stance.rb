class Stance < ActiveRecord::Base
  belongs_to :poll, required: true
  belongs_to :poll_option, required: true
  belongs_to :participant, polymorphic: true, required: true

  before_create :deactivate_previous_stances

  private

  def deactivate_previous_stances
    self.poll.stances.where(participant: self.participant).without(self).update_all(latest: false)
  end
end
