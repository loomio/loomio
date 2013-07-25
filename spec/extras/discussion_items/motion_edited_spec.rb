describe DiscussionItems::MotionEdited do
  let(:event) { stub(:event) }
  let(:motion) { stub(:motion) }
  let(:item) { DiscussionItems::MotionEdited.new(event, motion) }

  it "#icon returns a string indicating the icon-class"

  it "#actor returns the user who edited the close date" do
    event.stub(:user).and_return("bob")
    item.actor.should == item.event.user
  end

  it "#header returns a string" do
    item.header.should == I18n.t('discussion_items.motion_edited')
  end

  it "#group returns the motions's group" do
    item.stub_chain(:motion, :group).and_return("goob")
    item.group.should == item.motion.group
  end

  it "#body returns the edit message from the editor" do
    event.stub(:created_at).and_return("now")
    item.stub_chain(:motion, :version_at, :edit_message).and_return("blah")
    item.body.should == item.motion.version_at("now").edit_message
  end

  it "#time returns the time the close date was edited" do
    item.stub_chain(:event, :created_at).and_return("blah")
    item.time.should == item.event.created_at
  end
end
