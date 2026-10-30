class PollOption < ApplicationRecord
  include Translatable
  is_translatable on: [ :name, :meaning, :prompt ]

  belongs_to :poll
  validates :name, presence: true

  has_many :stance_choices, dependent: :destroy
  has_many :stances, -> { where("stances.revoked_at IS NULL") }, through: :stance_choices
  has_many :anonymous_ballot_choices, dependent: :restrict_with_error

  validates :test_operator, inclusion: { in: [ 'gte', 'lte' ] }, allow_nil: true
  normalizes :test_percent, with: ->(v) { v.nil? ? nil : [ [ v, 0 ].max, 100 ].min }
  validates :test_against, inclusion: { in: [ 'score_percent', 'voter_percent' ] }, allow_nil: true
  validate :cannot_change_after_anonymous_ballot, on: :update

  delegate :content_locale, to: :poll

  def update_counts!
    if poll.anonymous?
      choices = anonymous_ballot_choices
      score_total = choices.sum(:score)
      vote_count = choices.distinct.count(:anonymous_ballot_id)
      return update_columns(
        scores_by_voter: {},
        total_score: score_total,
        unweighted_score: score_total,
        vote_count: vote_count,
        vote_weight: vote_count
      )
    end

    # One aggregate query yields the weighted total and the totals that weighted
    # results need, so reading results never sums stance choices per option.
    score_total, unweighted_score, vote_weight = stance_choices.latest.pick(
      Arel.sql('COALESCE(SUM(stance_choices.score * stances.weight), 0)'),
      Arel.sql('COALESCE(SUM(stance_choices.score), 0)'),
      Arel.sql('COALESCE(SUM(stances.weight), 0)')
    )

    update_columns(
      scores_by_voter: poll.anonymous ? {} : stance_choices.latest.where('stances.participant_id is not null').includes(:stance).map { |c| [ c.stance.participant_id, c.score ] }.to_h,
      total_score: score_total,
      unweighted_score: unweighted_score,
      vote_count: stances.latest.count,
      vote_weight: vote_weight
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
        'block' => AppConfig.colors['proposal'][3]
      }.fetch(icon, AppConfig.colors['proposal'][0])
    else
      AppConfig.colors.dig('poll', self.priority % AppConfig.colors.length)
    end
  end

  # Only the time poll grid reads each voter's score from results. Other poll
  # types would send every voter's score for every option.
  def scores_by_voter_for_results
    poll.poll_type == 'availability' ? scores_by_voter : {}
  end

  def voter_ids
    # this is a hack, we both know this
    # some polls 0 is a vote, others it is not
    if poll.poll_type == 'availability'
      scores_by_voter.keys.map(&:to_i)
    else
      scores_by_voter.filter { |id, score| score != 0 }.keys.map(&:to_i)
    end
  end

  def average_score
    return 0 if vote_count == 0

    (total_score.to_f / vote_count).round(2)
  end

  def weighted_average_score
    return 0 if vote_weight == 0

    (total_score / vote_weight).round(2).to_f
  end

  private

  def cannot_change_after_anonymous_ballot
    return unless poll.anonymous? && poll.anonymous_ballots.exists?
    return unless changes_to_save.except("updated_at").any?

    errors.add(:base, :anonymous_ballot_configuration_frozen)
  end

end
