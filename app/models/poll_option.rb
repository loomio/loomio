class PollOption < ApplicationRecord
  include Translatable
  
  belongs_to :poll
  validates :name, presence: true

  has_many :stance_choices, dependent: :destroy
  has_many :stances, through: :stance_choices

  is_translatable on: [:name, :meaning]

  scope :dangling, -> { joins('left join polls on polls.id = poll_id').where('polls.id is null') }

  def update_counts!
    update_columns(
      voter_scores: poll.anonymous ? {} : stance_choices.latest.where('stances.participant_id is not null').includes(:stance).map { |c| [c.stance.participant_id, c.score] }.to_h,
      total_score: stance_choices.latest.sum(:score),
      voter_count: stances.latest.count
    )
  end

  def icon
    self[:icon] || {
      agree: 'agree',
      disagree: 'disagree',
      abstain: 'abstain',
      block: 'block',
      consent: 'agree',
      objection: 'disagree',
      yes: 'agree',
      no: 'disagree'
    }[name.to_sym]
  end

  def color
    if poll.vote_method == 'show_thumbs'
      {
        'agree' => AppConfig.colors['proposal'][0],
        'abstain' => AppConfig.colors['proposal'][1],
        'disagree' => AppConfig.colors['proposal'][2],
        'block' => AppConfig.colors['proposal'][3],
      }.fetch(icon, AppConfig.colors['proposal'][0])
    else
      AppConfig.colors.dig('poll', self.priority % AppConfig.colors.length)
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
