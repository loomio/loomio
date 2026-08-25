class StanceChoice < ApplicationRecord
  belongs_to :poll_option
  belongs_to :stance
  has_one :poll, through: :poll_option

  validate :poll_option_belongs_to_stance_poll
  validates :score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :latest, -> { joins(:stance).where('stances.latest': true).where('stances.revoked_at': nil) }
  scope :reasons_first, -> {
    joins(:stance).order(Arel.sql("CASE coalesce(stances.reason, '') WHEN '' THEN 1 ELSE 0 END"))
                  .order(:created_at)
  }

  def rank
    case poll.poll_type
    when 'ranked_choice'
      self.poll.minimum_stance_choices - self.score + 1
    when 'stv'
      self.score
    end
  end

  def rank_or_score
    rank || score
  end

  private

  def poll_option_belongs_to_stance_poll
    return unless stance && poll_option

    errors.add(:poll_option, :invalid) unless stance.poll == poll_option.poll
  end
end
