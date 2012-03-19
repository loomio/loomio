class Vote < ActiveRecord::Base
  class UserInGroupValidator < ActiveModel::EachValidator
    def validate_each(object, attribute, value)
      unless object.motion.group.users.include? value
        object.errors.add attribute, "must belong to the motion's group to vote."
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
  validates :user, user_in_group: true

  scope :for_user, lambda {|user| where(:user_id => user)}

  delegate :name, :to => :user, :prefix => :user

  def position=(new_position)
    if new_position == "block" && self.position != "block"
      MotionMailer.motion_blocked(self)
    end
    super(new_position)
  end

  def can_be_edited_by?(current_user)
    current_user && user == current_user
  end
end
