class Motion < ApplicationRecord
  belongs_to :author, class_name: 'User'
  belongs_to :user, foreign_key: 'author_id' # duplicate author relationship for eager loading
  belongs_to :outcome_author, class_name: 'User'
  has_one :poll

  belongs_to :discussion
  has_one :group, through: :discussion

  has_many :votes,         -> { includes(:user) },  dependent: :destroy
  has_many :unique_votes,  -> { includes(:user).where(age: 0) }, class_name: 'Vote'
  has_many :did_not_votes, -> { includes(:user) }, dependent: :destroy
  has_many :did_not_voters, through: :did_not_votes, source: :user
  has_many :events,        -> { includes(:eventable) }, as: :eventable, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy

  validates_presence_of :name, :discussion, :author, :closing_at
  validate :closes_in_future_unless_closed

  validates_length_of :name, maximum: 250

  delegate :email, to: :author, prefix: :author
  delegate :name, to: :author, prefix: :author
  delegate :members, :full_name, to: :group, prefix: :group
  delegate :email_new_motion?, to: :group, prefix: :group
  delegate :name_and_email, to: :user, prefix: :author
  delegate :locale, to: :user
  delegate :followers, to: :discussion
  delegate :title, to: :discussion, prefix: :discussion
  has_paper_trail only: [:name, :description, :closing_at, :outcome]

  after_initialize :set_default_closing_at

  scope :voting,                   -> { where(closed_at: nil).order(closed_at: :asc) }
  scope :lapsed,                   -> { where('closing_at < ?', Time.now) }
  scope :lapsed_but_not_closed,    -> { voting.lapsed }
  scope :closed,                   -> { where('closed_at IS NOT NULL').order(closed_at: :desc) }
  scope :order_by_latest_activity, -> { order('last_vote_at desc') }
  scope :visible_to_public,        -> { joins(:discussion).merge(Discussion.visible_to_public) }
  scope :voting_or_closed_after,   -> (time) { where('motions.closed_at IS NULL OR (motions.closed_at > ?)', time) }
  scope :closing_in_24_hours,      -> { where('motions.closing_at > ? AND motions.closing_at <= ?', Time.now, 24.hours.from_now) }
  scope :with_outcomes,            -> { where('motions.outcome IS NOT NULL AND motions.outcome != ?', '') }

  # recency threshold is the minimum length of time for a new motion_closing_soon event to
  # be published. So, if the proposal is extended by 2 hours, we don't want to publish another
  # motion closing soon event, but if it's extended by 10 days, we do.
  scope :closing_soon_not_published, ->(timeframe, recency_threshold = 2.days.ago) do
     voting
    .distinct
    .where(closing_at: timeframe)
    .where("NOT EXISTS (SELECT 1 FROM events
                WHERE events.created_at     > ? AND
                      events.eventable_id   = motions.id AND
                      events.eventable_type = 'Motion' AND
                      events.kind           = 'motion_closing_soon')", recency_threshold)
  end

  def proposal_title
    name
  end

  def grouped_unique_votes
    order = ['block', 'no', 'abstain', 'yes']
    unique_votes.sort do |a,b|
      order.index(a.position) <=> order.index(b.position)
    end
  end

  def title
    name
  end

  def user
    author
  end

  def voters
    votes.map(&:user).uniq.compact
  end

  def group_id
    group.id
  end

  def voting?
    closed_at.nil?
  end

  def closed?
    closed_at.present?
  end

  def needs_to_be_closed?
    (!closed? and closing_at < Time.now)
  end

  def non_voters_count
    members_count - voters_count
  end

  def close!
    did_not_votes.delete_all
    did_not_votes.import (group_members - voters).map { |user| did_not_votes.build(user: user) }, validate: false
    update(closed_at: Time.now, members_count: group.memberships_count)
  end

  # map of position and votes
  def vote_counts
    {'yes' => yes_votes_count,
     'abstain' => abstain_votes_count,
     'no' => no_votes_count,
     'block' => block_votes_count}
  end

  def restricted_changes_made?
    (changed & ['name', 'description']).any?
  end

  def can_be_edited?
    !persisted? || (voting? && (total_votes_count == 0 || group.motions_can_be_edited?))
  end

  # number of final votes
  def total_votes_count
    vote_counts.values.sum
  end

  # number of vote records - ie: including changes to votes
  # not to be confused with vote_counts (which is why we call it activity_count)
  def activity_count
    votes_count
  end

  def members_count
    if voting?
      group.memberships_count
    else
      self[:members_count]
    end
  end

  def members_not_voted
    if voting?
      group.members - voters
    else
      did_not_voters
    end
  end

  def percent_voted
    if members_count == 0
      0
    else
      (voters_count/members_count.to_f * 100).round
    end
  end

  # recount all the final votes.
  # rather expensive
  def update_vote_counts!
    position_counts = {}

    Vote::POSITIONS.each do |position|
      position_counts[position] = 0
    end

    reload.unique_votes.each do |vote|
      position_counts[vote.position] += 1
    end

    Vote::POSITIONS.each do |position|
      self.send("#{position}_votes_count=", position_counts[position])
    end

    # set the activity count
    self[:votes_count] = votes.count

    save(validate: false)
  end

  def user_has_voted?(user)
    return false if user.nil?
    votes.for_user(user.id).exists?
  end

  def closed_or_closing_at
    closed_at || closing_at
  end

  private

  def closes_in_future_unless_closed
    unless self.closed?
      if closing_at < Time.zone.now
        errors.add(:closing_at, I18n.t("validate.motion.must_close_in_future"))
      end
    end
  end

  def set_default_closing_at
    self.closing_at ||= (Time.zone.now + 3.days).at_beginning_of_hour
  end
end
