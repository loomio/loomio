describe DiscussionItems::NewMotion do
  let(:motion) { double(:motion) }
  let(:item) { DiscussionItems::NewMotion.new(motion) }

  it "#actor returns the user who created a motion" do
    actor = double(:actor)
    item.stub_chain(:motion, :author).and_return(actor)
    expect(item.actor).to eq item.motion.author
  end

  it "#header returns a string" do
    expect(item.header).to eq I18n.t('discussion_items.new_motion') + ": "
  end

  it "#group returns the motion's group" do
    item.stub_chain(:motion, :group).and_return("goob")
    expect(item.group).to eq item.motion.group
  end

  it "#body returns the motion's name with a space at front" do
    item.stub_chain(:motion, :name).and_return("goob")
    expect(item.body).to eq " #{item.motion.name}"
  end

  it "#time returns the time the motion was created at" do
    item.stub_chain(:motion, :created_at).and_return("blah")
    expect(item.time).to eq item.motion.created_at
  end
end
