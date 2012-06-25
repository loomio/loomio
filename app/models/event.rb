class Event < ActiveRecord::Base
  KINDS = ["new_discussion"]

  has_many :notifications
  belongs_to :discussion

  validates_inclusion_of :kind, :in => KINDS

  attr_accessible :kind, :discussion

  def self.new_discussion!(discussion)
    event = create!(:kind => "new_discussion", :discussion => discussion)
    discussion.group.users.each do |user|
      unless user == discussion.author
        event.notifications.create! :user => user
      end
    end
    event
  end
end
