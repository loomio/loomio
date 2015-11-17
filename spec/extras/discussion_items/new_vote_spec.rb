describe DiscussionItems::NewVote do
  let(:user) { create(:user) }
  let(:vote) { create(:vote, user: user) }
  let(:item) { DiscussionItems::NewVote.new(vote) }

  it "#actor returns the user who voted" do
    expect(item.actor).to eq item.vote.user
  end

  it "#header returns a string" do
    expect(item.header).to match vote.position_to_s
  end

  it "#group returns the motion's group" do
    expect(item.group).to eq item.vote.discussion.group
  end

  context "user has given a statement" do
    it "#body returns the users statement with a space at front" do
      expect(item.body).to eq " #{item.vote.statement}"
    end
  end

  it "#time returns the time the motion was created at" do
    expect(item.time).to eq item.vote.created_at
  end
end
