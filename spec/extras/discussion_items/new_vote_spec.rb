describe DiscussionItems::NewVote do
  let(:vote) { double(:vote) }
  let(:item) { DiscussionItems::NewVote.new(vote) }

  it "#icon returns a string indicating the icon-class"

  it "#actor returns the user who voted" do
    actor = double(:actor)
    item.stub_chain(:vote, :user).and_return(actor)
    expect(item.actor).to eq item.vote.user
  end

  it "#header returns a string"

  it "#group returns the motion's group" do
    item.stub_chain(:vote, :discussion, :group).and_return("goob")
    expect(item.group).to eq item.vote.discussion.group
  end

  context "user has given a statement" do
    before { item.stub_chain(:vote, :statement).and_return(double("It's furry!")) }

    it "#body returns the users statement with a space at front" do
      expect(item.body).to eq " #{item.vote.statement}"
    end
  end

  it "#time returns the time the motion was created at" do
    item.stub_chain(:vote, :created_at).and_return("blah")
    expect(item.time).to eq item.vote.created_at
  end
end
