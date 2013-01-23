describe DiscussionItems::NewVote do
  let(:vote) { stub(:vote) }
  let(:item) { DiscussionItems::NewVote.new(vote) }

  it "#icon returns a string indicating the icon-class"

  it "#actor returns the user who voted" do
    actor = stub(:actor)
    item.stub_chain(:vote, :user).and_return(actor)
    item.actor.should == item.vote.user
  end

  it "#header returns a string"

  it "#group returns the motion's group" do
    item.stub_chain(:vote, :discussion, :group).and_return("goob")
    item.group.should == item.vote.discussion.group
  end

  context "user has given a statement" do
    before { item.stub_chain(:vote, :statement).and_return(stub("It's furry!")) }

    it "#body returns the users statement in quotes" do
      item.body.should == "\"#{item.vote.statement}\""
    end
  end

  it "#time returns the time the motion was created at" do
    item.stub_chain(:vote, :created_at).and_return("blah")
    item.time.should == item.vote.created_at
  end
end
