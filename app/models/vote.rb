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
          "can only be modified while the motion is open."
      end
    end
  end

  POSITIONS = %w[yes abstain no block]
  POSITION_VERBS = { 'yes' => 'agreed', 'abstain' => 'abstained',
                     'no' => 'disagreed', 'block' => 'blocked' }
  belongs_to :motion
  belongs_to :user
  has_many :events, :as => :eventable, :dependent => :destroy

  validates_presence_of :motion, :user, :position
  validates_inclusion_of :position, in: POSITIONS
  validates_length_of :statement, maximum: 250
  validates :user_id, user_can_vote: true
  validates :position, :statement, closable: true

  scope :for_user, lambda {|user| where(:user_id => user)}

  attr_accessible :position, :statement

  delegate :name, :to => :user, :prefix => :user
  delegate :group, :discussion, :to => :motion
  delegate :users, :to => :group, :prefix => :group
  delegate :author, :to => :motion, :prefix => :motion
  delegate :author, :to => :discussion, :prefix => :discussion
  delegate :name, :to => :motion, :prefix => :motion
  delegate :name, :full_name, :to => :group, :prefix => :group

  after_save :send_notifications

  after_create :update_motion_last_vote_at
  after_destroy :update_motion_last_vote_at

  def can_be_edited_by?(current_user)
    current_user && user == current_user
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
    return POSITION_VERBS[self.position]
  end

  def previous_vote
    prev_position = Vote.find(:first,
      :conditions => [
        'motion_id = ? AND user_id = ? AND created_at < ?',
          motion.id, self.user_id, self.created_at
      ]
    )
    return prev_position
  end

  def previous_position
    previous_vote.position if previous_vote
  end

  private
    def update_motion_last_vote_at
      motion.last_vote_at = motion.latest_vote_time
      motion.save!
    end

    def send_notifications
      if position == "block" && previous_vote != "block"
        MotionMailer.motion_blocked(self).deliver
      end
    end
end
