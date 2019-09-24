class Stance < ApplicationRecord
  include CustomCounterCache::Model
  include HasMentions
  include Reactable
  include HasEvents
  include HasCreatedEvent

  ORDER_SCOPES = ['newest_first', 'oldest_first', 'priority_first', 'priority_last']
  include Translatable
  is_translatable on: :reason
  is_mentionable  on: :reason
  include HasRichText

  is_rich_text    on: :reason

  belongs_to :poll, required: true
  has_many :stance_choices, dependent: :destroy
  has_many :poll_options, through: :stance_choices

  has_paper_trail only: [:reason]
  define_counter_cache(:versions_count)  { |stance| stance.versions.count }
  def self.always_versioned_fields
    [:reason]
  end


  accepts_nested_attributes_for :stance_choices
  attr_accessor :visitor_attributes

  belongs_to :participant, class_name: 'User', required: true
  alias :user :participant
  alias :author :participant

  update_counter_cache :poll, :stances_count
  update_counter_cache :poll, :undecided_count

  scope :latest, -> { where(latest: true) }
  scope :newest_first,   -> { order(created_at: :desc) }
  scope :oldest_first,   -> { order(created_at: :asc) }
  scope :priority_first, -> { joins(:poll_options).order('poll_options.priority ASC') }
  scope :priority_last,  -> { joins(:poll_options).order('poll_options.priority DESC') }
  scope :with_reason,    -> { where("reason IS NOT NULL OR reason != ''") }
  scope :in_organisation, ->(group) { joins(:poll).where("polls.group_id": group.id_and_subgroup_ids) }

  validate :enough_stance_choices
  validate :total_score_is_valid
  validate :participant_is_complete
  validates :reason, length: { maximum: 500 }


  delegate :locale,         to: :author
  delegate :group,          to: :poll, allow_nil: true
  delegate :mailer,         to: :poll, allow_nil: true
  delegate :groups,         to: :poll
  delegate :group_id,       to: :poll
  delegate :guest_group,    to: :poll
  delegate :guest_group_id, to: :poll
  delegate :discussion_id,  to: :poll
  delegate :members,        to: :poll

  alias :author :participant

  def parent_event
    poll.created_event
  end

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

  def participant_for_client(user: nil)
    if !self.poll.anonymous || (user&.id == self.participant_id)
      self.participant
    else
      LoggedOutUser.new(name: I18n.t(:"common.anonymous"))
    end
  end

  private

  def enough_stance_choices
    return unless poll.require_stance_choices
    if stance_choices.length < poll.minimum_stance_choices
      errors.add(:stance_choices, I18n.t(:"stance.error.too_short"))
    end
  end

  def total_score_is_valid
    return unless poll.poll_type == 'dot_vote'
    if stance_choices.map(&:score).sum > poll.dots_per_person.to_i
      errors.add(:dots_per_person, "Too many dots")
    end
  end

  def participant_is_complete
    participant.tap(&:valid?).errors.map { |key, err| errors.add(:"participant_#{key}", err)}
  end
end
