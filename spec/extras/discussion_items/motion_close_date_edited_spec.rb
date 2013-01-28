describe DiscussionItems::MotionCloseDateEdited do
  let(:event) { stub(:event) }
  let(:motion) { stub(:motion) }
  let(:item) { DiscussionItems::MotionCloseDateEdited.new(event, motion) }

  it "#icon returns a string indicating the icon-class"

  it "#actor returns the user who edited the close date" do
    actor = stub(:actor)
    item.stub_chain(:event, :user).and_return(actor)
    item.actor.should == item.event.user
  end

  it "#header returns a string" do
    item.header.should == I18n.t('discussion_items.motion_close_date_edited')
  end

  it "#group returns the discussion's group" do
    item.stub_chain(:motion, :group).and_return("goob")
    item.group.should == item.motion.group
  end

  it "#time returns the time the close date was edited" do
    item.stub_chain(:event, :created_at).and_return("blah")
    item.time.should == item.event.created_at
  end
end
