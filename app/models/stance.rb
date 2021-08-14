class Stance < ApplicationRecord
  include CustomCounterCache::Model
  include HasMentions
  include Reactable
  include HasEvents
  include HasCreatedEvent
  include HasVolume

  extend HasTokens
  initialized_with_token :token

  ORDER_SCOPES = ['newest_first', 'oldest_first', 'priority_first', 'priority_last']
  include Translatable
  is_translatable on: :reason
  is_mentionable  on: :reason
  include HasRichText

  is_rich_text    on: :reason

  belongs_to :poll, required: true
  belongs_to :inviter, class_name: 'User'

  has_many :stance_choices, dependent: :destroy
  has_many :poll_options, through: :stance_choices

  has_paper_trail only: [:reason, :option_scores]

  accepts_nested_attributes_for :stance_choices

  belongs_to :participant, class_name: 'User', required: true

  alias :user :participant
  alias :author :participant

  scope :latest,         -> { where(latest: true).where(revoked_at: nil) }
  scope :admin,         ->  { where(admin: true) }
  scope :newest_first,   -> { order("cast_at DESC NULLS LAST") }
  scope :undecided_first, -> { order("cast_at DESC NULLS FIRST") }
  scope :oldest_first,   -> { order(created_at: :asc) }
  scope :priority_first, -> { joins(:poll_options).order('poll_options.priority ASC') }
  scope :priority_last,  -> { joins(:poll_options).order('poll_options.priority DESC') }
  scope :with_reason,    -> { where("reason IS NOT NULL OR reason != ''") }
  scope :in_organisation, ->(group) { joins(:poll).where("polls.group_id": group.id_and_subgroup_ids) }
  scope :decided,        -> { where("stances.cast_at IS NOT NULL") }
  scope :undecided,      -> { where("stances.cast_at IS NULL") }

  scope :redeemable, -> { where('stances.inviter_id IS NOT NULL
                             AND stances.cast_at IS NULL
                             AND stances.accepted_at IS NULL
                             AND stances.revoked_at IS NULL') }

  validate :enough_stance_choices
  validate :total_score_is_valid
  validates :reason, length: { maximum: 500 }, unless: -> { poll.allow_long_reason }

  delegate :group,          to: :poll, allow_nil: true
  delegate :mailer,         to: :poll, allow_nil: true
  delegate :group_id,       to: :poll
  delegate :discussion_id,  to: :poll
  delegate :discussion,     to: :poll
  delegate :members,        to: :poll
  delegate :guests,         to: :poll
  delegate :title,          to: :poll

  alias :author :participant

  before_save :update_option_scores
  after_save :update_versions_count!

  def update_option_scores
    self.option_scores = stance_choices.map { |sc| [sc.poll_option_id, sc.score] }.to_h
  end

  def update_option_scores!
    update_columns(option_scores: update_option_scores)
  end

  def update_versions_count!
    update_columns(versions_count: versions.count)
  end

  def author_id
    participant_id
  end

  def user_id
    participant_id
  end

  def locale
    author&.locale || group&.locale || poll.author.locale
  end

  def add_to_discussion?
    poll.discussion_id &&
    poll.stances_in_discussion &&
    !body_is_blank? &&
    !Event.where(eventable: self,
                 discussion_id: poll.discussion_id,
                 kind: ['stance_created', 'stance_updated']).exists?
  end

  def body
    reason
  end

  def body_format
    reason_format
  end

  def parent_event
    poll.created_event
  end

  def discarded?
    false
  end

  def choice=(choice)
    self.cast_at ||= Time.zone.now
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

  def participant(bypass = false)
    super() if bypass
    (!participant_id || poll.anonymous?) ? AnonymousUser.new : super()
  end

  def real_participant
    User.find_by(id: participant_id)
  end

  def score_for(option)
    option_scores[option.id] || 0
  end

  private

  def enough_stance_choices
    return unless self.cast_at
    if poll.require_stance_choices
      if stance_choices.length < poll.minimum_stance_choices
        errors.add(:stance_choices, I18n.t(:"stance.error.too_short"))
      end
    end

    if poll.require_all_choices
      if stance_choices.length < poll.poll_options.length
        errors.add(:stance_choices, I18n.t(:"stance.error.too_short"))
      end
    end
  end

  def total_score_is_valid
    return unless poll.poll_type == 'dot_vote'
    if stance_choices.map(&:score).sum > poll.dots_per_person.to_i
      errors.add(:dots_per_person, "Too many dots")
    end
  end
end
