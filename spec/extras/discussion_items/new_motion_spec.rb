describe DiscussionItems::NewMotion do
  let(:motion) { stub(:motion) }
  let(:item) { DiscussionItems::NewMotion.new(motion) }

  it "#icon returns a string indicating the icon-class"

  it "#actor returns the user who created a motion" do
    actor = stub(:actor)
    item.stub_chain(:motion, :author).and_return(actor)
    item.actor.should == item.motion.author
  end

  it "#header returns a string" do
    item.header.should == I18n.t('discussion_items.new_motion') + ": "
  end

  it "#group returns the motion's group" do
    item.stub_chain(:motion, :group).and_return("goob")
    item.group.should == item.motion.group
  end

  it "#body returns the motion's name in quotes" do
    item.stub_chain(:motion, :name).and_return("goob")
    item.body.should == " \"#{item.motion.name}\""
  end

  it "#time returns the time the motion was created at" do
    item.stub_chain(:motion, :created_at).and_return("blah")
    item.time.should == item.motion.created_at
  end
end
