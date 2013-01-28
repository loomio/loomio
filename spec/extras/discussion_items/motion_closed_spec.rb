describe DiscussionItems::MotionClosed do
  let(:event) { stub(:event) }
  let(:motion) { stub(:motion) }
  let(:item) { DiscussionItems::MotionClosed.new(event, motion) }

  it "#icon returns a string indicating the icon-class"

  context "Motion is closed by a user" do
    before { item.stub_chain(:event, :user).and_return(stub(:user)) }

    it "#actor returns the user who created a discussion" do
      actor = stub(:actor)
      item.actor.should == item.event.user
    end

    it "#header returns a string" do
      item.header.should == I18n.t('discussion_items.motion_closed.by_user') + ": "
    end
  end

  context "Motion close date expires" do
    before { item.stub_chain(:event, :user).and_return(nil) }

    it "#actor returns an empty string" do
      item.actor.should == ""
    end

    it "#header returns a string" do
      item.header.should == I18n.t('discussion_items.motion_closed.by_expirey') + ": "
    end
  end

  it "#group returns the discussion's group" do
    item.stub_chain(:motion, :group).and_return("goob")
    item.group.should == item.motion.group
  end

  it "#body returns the motion's name in quotes" do
    item.stub_chain(:motion, :name).and_return("goob")
    item.body.should == " \"#{item.motion.name}\""
  end

  it "#time returns the time the motion was closed" do
    item.stub_chain(:event, :created_at).and_return("blah")
    item.time.should == item.event.created_at
  end
end
