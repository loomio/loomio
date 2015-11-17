describe DiscussionItems::MotionCloseDateEdited do
  let(:event) { double(:event) }
  let(:motion) { double(:motion) }
  let(:item) { DiscussionItems::MotionCloseDateEdited.new(event, motion) }

  it "#actor returns the user who edited the close date" do
    actor = double(:actor)
    item.stub_chain(:event, :user).and_return(actor)
    expect(item.actor).to eq item.event.user
  end

  it "#header returns a string" do
    expect(item.header).to eq I18n.t('discussion_items.motion_close_date_edited')
  end

  it "#group returns the discussion's group" do
    item.stub_chain(:motion, :group).and_return("goob")
    expect(item.group).to eq item.motion.group
  end

  it "#time returns the time the close date was edited" do
    item.stub_chain(:event, :created_at).and_return("blah")
    expect(item.time).to eq item.event.created_at
  end
end
