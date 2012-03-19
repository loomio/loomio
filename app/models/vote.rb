class Vote < ActiveRecord::Base
  class UserInGroupValidator < ActiveModel::EachValidator
    def validate_each(object, attribute, value)
      unless value && object.motion.group.users.include?(User.find(value))
        object.errors.add attribute, "must belong to the motion's group to vote."
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
  # TODO get counter_cache working
  belongs_to :motion#, :counter_cache => :votes_counter
  belongs_to :user

  validates_presence_of :motion, :user, :position
  validates_inclusion_of :position, in: POSITIONS
  validates_uniqueness_of :user_id, scope: :motion_id
  validates_length_of :statement, maximum: 250
  validates :user_id, user_in_group: true
  validates :position, :statement, closable: true

  scope :for_user, lambda {|user| where(:user_id => user)}

  attr_accessor :old_position

  delegate :name, :to => :user, :prefix => :user

  after_save :send_notifications

  def position=(new_position)
    self.old_position = position
    super(new_position)
  end

  def can_be_edited_by?(current_user)
    current_user && user == current_user
  end

  private
    def send_notifications
      debugger
      if position == "block" && old_position != "block"
        MotionMailer.motion_blocked(self)
      end
    end
end
