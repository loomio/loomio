class PollOption < ApplicationRecord
  include CustomCounterCache::Model
  include FormattedDateHelper

  belongs_to :poll
  validates :name, presence: true

  has_many :stance_choices, dependent: :destroy
  has_many :stances, through: :stance_choices

  def voter_scores
    if self[:voter_scores].length == 0 and poll.decided_voters_count > 0
      update_voter_scores!
    end
    self[:voter_scores]
  end

  def update_voter_scores
    self.voter_scores = stance_choices.latest.includes(:stance).map { |c| [c.stance.participant_id, c.score] }.to_h
  end

  def update_voter_scores!
    update_voter_scores
    update_columns(voter_scores: self[:voter_scores])
  end

  def total_score
    if self[:total_score] == 0 and poll.decided_voters_count > 0
      update_total_score!
    end
    self[:total_score]
  end

  def update_total_score
    self.total_score = stance_choices.latest.sum(:score)
  end

  def update_total_score!
    update_total_score
    update_columns(total_score: self[:total_score])
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
