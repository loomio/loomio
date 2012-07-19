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
  delegate :group, :to => :motion
  delegate :users, :to => :group, :prefix => :group
  delegate :discussion, :to => :motion
  delegate :author, :to => :motion, :prefix => :motion
  delegate :author, :to => :discussion, :prefix => :discussion
  delegate :name, :to => :motion, :prefix => :motion
  delegate :name, :full_name, :to => :group, :prefix => :group

  after_save :send_notifications
  after_save :update_activity

  def previous_position
    previous_vote = Vote.order("id DESC").offset(1).limit(1).first
    previous_vote.position if previous_vote
  end

  def can_be_edited_by?(current_user)
    current_user && user == current_user
  end

  def self.unique_votes(motion)
    Vote.find_by_sql("SELECT * FROM votes a WHERE created_at = (SELECT MAX(created_at) as created_at FROM votes b WHERE a.user_id = b.user_id AND motion_id = #{motion.id} )")
  end

  private
    def update_activity
      motion.discussion.update_activity
    end

    def send_notifications
      if position == "block" && previous_position != "block"
        MotionMailer.motion_blocked(self).deliver
      end
    end
end
