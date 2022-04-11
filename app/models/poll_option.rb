class PollOption < ApplicationRecord
  belongs_to :poll
  validates :name, presence: true

  has_many :stance_choices, dependent: :destroy
  has_many :stances, through: :stance_choices

  scope :dangling, -> { joins('left join polls on polls.id = poll_id').where('polls.id is null') }

  def update_counts!
    update_columns(
      voter_scores: poll.anonymous ? {} : stance_choices.latest.where('stances.participant_id is not null').includes(:stance).map { |c| [c.stance.participant_id, c.score] }.to_h,
      total_score: stance_choices.latest.sum(:score),
      voter_count: stances.latest.count
    )
  end

  def color
    if poll.poll_type == 'proposal'
      {
        'agree' => AppConfig.colors['proposal'][0],
        'abstain' => AppConfig.colors['proposal'][1],
        'disagree' => AppConfig.colors['proposal'][2],
        'block' => AppConfig.colors['proposal'][3],
        'consent' => AppConfig.colors['proposal'][0],
        'tension' => AppConfig.colors['proposal'][1],
        'objection' => AppConfig.colors['proposal'][2]
      }.fetch(name, AppConfig.colors['proposal'][0])
    else
      AppConfig.colors.dig(poll.poll_type, self.priority % AppConfig.colors.length)
    end
  end

  def voter_ids
    # this is a hack, we both know this
    # some polls 0 is a vote, others it is not
    if poll.poll_type == 'meeting'
      voter_scores.keys.map(&:to_i)
    else
      voter_scores.filter{|id, score| score != 0 }.keys.map(&:to_i)
    end
  end

  def average_score
    return 0 if voter_count == 0
    (total_score.to_f / voter_count.to_f)
  end
end
