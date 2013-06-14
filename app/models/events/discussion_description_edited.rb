class Events::DiscussionDescriptionEdited < Event
  def self.publish!(discussion, editor)
    create!(:kind => "discussion_description_edited", :eventable => discussion,
              :discussion_id => discussion.id, :user => editor)
  end
end
