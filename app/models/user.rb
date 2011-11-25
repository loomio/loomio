class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  has_many :membership_requests, 
           :conditions => {:access_level => 'request'}, 
           :class_name => 'Membership'
  has_many :memberships, 
           :conditions => {:access_level => Membership::MEMBER_ACCESS_LEVELS}
  has_many :groups, through: :memberships
end
