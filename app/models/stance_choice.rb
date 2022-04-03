class StanceChoice < ApplicationRecord
  belongs_to :poll_option
  belongs_to :stance
  has_one :poll, through: :poll_option
  delegate :has_variable_score, to: :poll, allow_nil: true

  validates_presence_of :poll_option
  validate :total_score_is_valid
  validates :score, numericality: { equal_to: 1 }, if: Proc.new { |sc| sc.stance && !sc.stance.cast_at && sc.poll && !sc.has_variable_score }

  scope :dangling, -> { joins('left join stances on stances.id = stance_id').where('stances.id': nil) }
  scope :latest, -> { joins(:stance).where('stances.latest': true).where('stances.revoked_at': nil) }
  scope :reasons_first, -> {
    joins(:stance).order(Arel.sql("CASE coalesce(stances.reason, '') WHEN '' THEN 1 ELSE 0 END"))
                  .order(:created_at)
  }

  def rank
    self.poll.minimum_stance_choices - self.score + 1 if poll.poll_type == 'ranked_choice'
  end

  def rank_or_score
    rank || score
  end

  private
  def total_score_is_valid
    return unless poll # when we are cloning records and poll is not saved yet

    if poll.custom_fields['min_score'] && score < poll.custom_fields['min_score'].to_i
      errors.add(:score, "Score lower than permitted min")
    end

    if poll.custom_fields['max_score'] && score > poll.custom_fields['max_score'].to_i
      errors.add(:score, "Score higher than permitted max")
    end
  end
end
