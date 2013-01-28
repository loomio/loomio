describe DiscussionItems::DiscussionDescriptionEdited do
  let(:event) { stub(:event) }
  let(:discussion) { stub(:discussion) }
  let(:item) { DiscussionItems::DiscussionDescriptionEdited.new(event, discussion) }

  it "#icon returns a string indicating the icon-class"

  it "#actor returns the user who edited the description" do
    actor = stub(:actor)
    item.stub_chain(:event, :user).and_return(actor)
    item.actor.should == item.event.user
  end

  it "#header returns a string" do
    item.header.should == I18n.t('discussion_items.discussion_description_edited')
  end

  it "#group returns the discussion's group" do
    item.stub_chain(:discussion, :group).and_return("goob")
    item.group.should == item.discussion.group
  end

  it "#time returns the time the discription's title was edited" do
    item.stub_chain(:event, :created_at).and_return("blah")
    item.time.should == item.event.created_at
  end
end
