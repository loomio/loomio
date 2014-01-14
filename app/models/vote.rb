class Vote < ActiveRecord::Base
  class UserCanVoteValidator < ActiveModel::EachValidator
    def validate_each(object, attribute, value)
      unless value && object.motion.can_be_voted_on_by?(User.find(value))
        object.errors.add attribute, "does not have permission to vote on motion."
      end
    end
  end
  class ClosableValidator < ActiveModel::EachValidator
    def validate_each(object, attribute, value)
      if object.motion && (not object.motion.voting?)
        object.errors.add attribute,
          "can only be modified while the motion is in voting phase."
      end
    end
  end

  POSITIONS = %w[yes abstain no block]

  belongs_to :motion, counter_cache: true
  belongs_to :user
  has_many :events, :as => :eventable, :dependent => :destroy

  validates_presence_of :motion, :user, :position
  validates_inclusion_of :position, in: POSITIONS
  validates_length_of :statement, maximum: 250
  validates :user_id, user_can_vote: true
  validates :position, :statement, closable: true

  scope :for_user, lambda {|user| where(:user_id => user)}

  delegate :name, :to => :user, :prefix => :user
  delegate :group, :discussion, :to => :motion
  delegate :users, :to => :group, :prefix => :group
  delegate :author, :to => :motion, :prefix => :motion
  delegate :author, :to => :discussion, :prefix => :discussion
  delegate :name, :to => :motion, :prefix => :motion
  delegate :name, :full_name, :to => :group, :prefix => :group

  after_save :update_motion_vote_counts
  after_create :update_motion_last_vote_at
  after_destroy :update_motion_last_vote_at, :update_motion_vote_counts

  def other_group_members
    group.users.where(User.arel_table[:id].not_eq(user.id))
  end

  def can_be_edited_by?(current_user)
    current_user && user == current_user
  end

  def author
    user
  end

  def self.unique_votes(motion)
    Vote.find_by_sql(
      "SELECT * FROM votes a WHERE created_at = (SELECT  MAX(created_at) as  created_at FROM votes b WHERE a.user_id = b.user_id AND motion_id = #{motion.id})
      ORDER   BY  Case    a.position
        When    'block'     Then    0
        When    'no'        Then    1
        When    'abstain'   Then    2
        When    'yes'       Then    3
        Else    -1
      End")
  end

  def position_to_s
    return I18n.t(self.position, scope: [:position_verbs, :past_tense])
  end

  def previous_vote
    user.votes.where(motion_id: motion_id).order('id desc').last
  end

  def previous_position
    previous_vote.position if previous_vote
  end

  private
  def update_motion_vote_counts
    unless motion.nil? || motion.discussion.nil?
      motion.update_vote_counts!
    end
  end

  def update_motion_last_vote_at
    unless motion.nil? || motion.discussion.nil?
      motion.last_vote_at = motion.latest_vote_time
      motion.save!
    end
  end
end
