class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  validates :name, :presence => true

  has_many :membership_requests, 
           :conditions => {:access_level => 'request'}, 
           :class_name => 'Membership'
  has_many :memberships, 
           :conditions => {:access_level => Membership::MEMBER_ACCESS_LEVELS}
  has_many :groups, through: :memberships
  has_many :votes


  def motions
    self.groups.collect{|g| g.motions.order('created_at DESC')}.flatten!
  end
 
  def motion_vote(motion)
    Vote.where('motion_id = ? AND user_id = ?', motion.id, self.id).first
  end

end

