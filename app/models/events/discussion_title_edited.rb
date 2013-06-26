class Events::DiscussionTitleEdited < Event
  def self.publish!(discussion, editor)
    create!(:kind => "discussion_title_edited", :eventable => discussion,
              :discussion_id => discussion.id, :user => editor)
  end
end
