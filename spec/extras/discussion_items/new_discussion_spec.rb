describe DiscussionItems::NewDiscussion do
  let(:event) { stub(:event) }
  let(:discussion) { stub(:discussion) }
  let(:item) { DiscussionItems::NewDiscussion.new(event, discussion) }

  it "#icon returns a string indicating the icon-class"

  it "#actor returns the user who created a discussion" do
    actor = stub(:actor)
    item.stub_chain(:discussion, :author).and_return(actor)
    item.actor.should == item.discussion.author
  end

  it "#header returns a string" do
    item.header.should == I18n.t('discussion_items.new_discussion') + ": "
  end

  it "#group returns the discussion's group" do
    item.stub_chain(:discussion, :group).and_return("goob")
    item.group.should == item.discussion.group
  end

  it "#body returns the discussion's title in quotes" do
    item.stub_chain(:event, :created_at).and_return("blah")
    item.stub_chain(:discussion, :version_at, :title).and_return("goob")
    item.body.should == " \"#{item.discussion.version_at.title}\""
  end

  it "#time returns the time the discussion was created at" do
    item.stub_chain(:discussion, :created_at).and_return("blah")
    item.time.should == item.discussion.created_at
  end
end
