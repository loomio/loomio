describe DiscussionItems::NewDiscussion do
  let(:event) { double(:event) }
  let(:discussion) { double(:discussion) }
  let(:item) { DiscussionItems::NewDiscussion.new(event, discussion) }

  it "#actor returns the user who created a discussion" do
    actor = double(:actor)
    item.stub_chain(:discussion, :author).and_return(actor)
    expect(item.actor).to eq item.discussion.author
  end

  it "#header returns a string" do
    expect(item.header).to eq I18n.t('discussion_items.new_discussion') + ": "
  end

  it "#group returns the discussion's group" do
    item.stub_chain(:discussion, :group).and_return("goob")
    expect(item.group).to eq item.discussion.group
  end

  it "#body returns the discussion's title with a space at front" do
    item.stub_chain(:event, :created_at).and_return("blah")
    item.stub_chain(:discussion, :version_at, :title).and_return("goob")
    expect(item.body).to eq " #{item.discussion.version_at.title}"
  end

  it "#time returns the time the discussion was created at" do
    item.stub_chain(:discussion, :created_at).and_return("blah")
    expect(item.time).to eq item.discussion.created_at
  end
end
