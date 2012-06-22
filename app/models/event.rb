class Event < ActiveRecord::Base
  KINDS = ["new_discussion"]

  belongs_to :discussion

  validates_inclusion_of :kind, :in => KINDS

  attr_accessible :kind, :discussion

  def self.new_discussion!(discussion)
    discussion.group.users.each do |user|
      unless user == discussion.author
        Notification.create!(kind: "new_discussion", user: user,
                             discussion: discussion)
      end
    end
    create!(kind: "new_discussion", discussion: discussion)
  end
end
