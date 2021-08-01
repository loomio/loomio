class PollOption < ApplicationRecord
  include FormattedDateHelper

  belongs_to :poll
  validates :name, presence: true

  has_many :stance_choices, dependent: :destroy
  has_many :stances, through: :stance_choices

  def total_score
    voter_scores.values.sum
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

  def update_score_counts
    update_columns(score_counts: stance_choices
      .latest
      .select('score, count(*) as count')
      .group(:score)
      .map { |c| [c.score.to_i, c.count] }
      .to_h
    )
  end

  def update_voter_scores
    update_columns(voter_scores:
      stance_choices
      .latest
      .includes(:stance)
      .where(poll_option_id: id)
      .limit(1000)
      .map { |c| [c.stance.participant_id, c.score] }
      .to_h
    )
  end

  def has_time?(value = nil)
    super(value || self.name)
  end

  def display_name(zone: nil)
    if poll.dates_as_options
      format_iso8601_for_humans(name, zone || poll.time_zone)
    elsif poll.poll_options_attributes.any?
      name.humanize
    else
      name
    end
  end
end
