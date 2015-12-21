describe DiscussionItems::MotionClosedByUser do
  let(:event) { double(:event) }
  let(:motion) { double(:motion) }
  let(:item) { DiscussionItems::MotionClosedByUser.new(event, motion) }

  context "Motion is closed by a user" do
    before { item.stub_chain(:event, :user).and_return(double(:user)) }

    it "#actor returns the user who created a discussion" do
      actor = double(:actor)
      expect(item.actor).to eq item.event.user
    end

    it "#header returns a string" do
      expect(item.header).to eq I18n.t('discussion_items.motion_closed.by_user') + ": "
    end
  end

  it "#group returns the discussion's group" do
    item.stub_chain(:motion, :group).and_return("goob")
    expect(item.group).to eq item.motion.group
  end

  it "#body returns the motion's name with a space at front" do
    item.stub_chain(:motion, :name).and_return("goob")
    expect(item.body).to eq " #{item.motion.name}"
  end

  it "#time returns the time the motion was closed" do
    item.stub_chain(:event, :created_at).and_return("blah")
    expect(item.time).to eq item.event.created_at
  end
end
