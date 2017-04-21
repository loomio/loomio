class Stance < ActiveRecord::Base
  include HasMentions

  ORDER_SCOPES = ['newest_first', 'oldest_first', 'priority_first', 'priority_last']

  is_mentionable  on: :reason

  belongs_to :poll, required: true
  has_many :stance_choices, dependent: :destroy
  has_many :poll_options, through: :stance_choices

  accepts_nested_attributes_for :stance_choices
  attr_accessor :visitor_attributes

  belongs_to :participant, polymorphic: true, required: true

  update_counter_cache :poll, :stances_count

  scope :latest, -> { where(latest: true) }

  scope :newest_first,   -> { order(created_at: :desc) }
  scope :oldest_first,   -> { order(created_at: :asc) }
  scope :priority_first, -> { joins(:poll_options).order('poll_options.priority ASC') }
  scope :priority_last,  -> { joins(:poll_options).order('poll_options.priority DESC') }
  scope :with_reason,    -> { where("reason IS NOT NULL OR reason != ''") }

  validate :enough_stance_choices
  validate :total_score_is_valid
  validate :participant_is_complete

  has_many :events, as: :eventable, dependent: :destroy

  delegate :group, to: :poll, allow_nil: true
  alias :author :participant

  def choice=(choice)
    if choice.kind_of?(Hash)
      self.stance_choices_attributes = poll.poll_options.where(name: choice.keys).map do |option|
        {poll_option_id: option.id,
         score: choice[option.name]}
      end
    else
      options = poll.poll_options.where(name: choice)
      self.stance_choices_attributes = options.map do |option|
        {poll_option_id: option.id}
      end
    end
  end

  private

  def enough_stance_choices
    return unless poll.require_stance_choice
    if stance_choices.empty?
      errors.add(:stance_choices, I18n.t(:"stance.error.too_short"))
    end
  end

  def total_score_is_valid
    return unless poll.poll_type == 'dot_vote'
    if stance_choices.map(&:score).sum > poll.custom_fields['dots_per_person'].to_i
      errors.add(:dots_per_person, "Too many dots")
    end
  end

  def participant_is_complete
    if participant&.name.blank?
      errors.add(:participant_name, I18n.t(:"activerecord.errors.messages.blank"))
      participant.errors.add(:name, I18n.t(:"activerecord.errors.messages.blank"))
    end
    if participant&.email.blank?
      errors.add(:participant_email, I18n.t(:"activerecord.errors.messages.blank"))
      participant.errors.add(:email, I18n.t(:"activerecord.errors.messages.blank"))
    end
  end
end
