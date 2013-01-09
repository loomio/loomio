describe NotificationItems::NewVote do
  let(:notification) { stub(:notification) }
  let(:item) { NotificationItems::NewVote.new(notification) }

  it "#actor returns the user who voted" do
    voter = stub(:user)
    notification.stub_chain(:eventable, :user).and_return(voter)
    item.actor.should == notification.eventable.user
  end

  it "#action_text returns a string" do
    position = notification.stub_chain(:eventable, :position).and_return("abstain")
    item.action_text.should == "abstained on the proposal"
  end

  it "#title returns the motion name" do
    notification.stub_chain(:eventable, :motion, :name).and_return("hello")
    item.title.should == notification.eventable.motion.name
  end

  it "#group_full_name returns the discussion's group name including a parent if there is one" do
    notification.stub_chain(:eventable, :group_full_name).and_return("goob")
    item.group_full_name.should == notification.eventable.group_full_name
  end

  it "#link returns a path to the motion" do
    item.stub_chain(:url_helpers, :discussion_path).and_return("/discussions/1/")
    notification.stub_chain(:eventable, :discussion).and_return(stub(:discussion))
    notification.stub_chain(:eventable, :motion, :id).and_return("123")
    item.link.should == "/discussions/1/?proposal=123"
  end
end
