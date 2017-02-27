class Visitor < ActiveRecord::Base
  include NullUser
  include HasGravatar

  before_create :generate_participation_token
  before_create :set_avatar_initials

  belongs_to :community, required: true, class_name: "Communities::Base"
  has_one :stance, as: :participant

  private

  def generate_participation_token
    self.participation_token ||= ::TokenGenerator.new(self).generate
  end
end
