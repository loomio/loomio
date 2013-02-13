require 'spec_helper'

describe Comment do
  let(:user) { stub_model(User) }
  let(:discussion) { stub_model(Discussion) }
  let(:comment) { Comment.create(commentable_id: discussion.id,
                   commentable_type: 'Discussion', user_id: user.id) }

  it { should have_many(:events).dependent(:destroy) }
  it { should respond_to(:uses_markdown) }

  describe "creating a comment on a discussion" do
    it "updates discussion.last_comment_at" do
      discussion = create(:discussion)
      discussion.last_comment_at = 2.days.ago
      discussion.save!
      comment = discussion.add_comment discussion.author, "hi"
      discussion.reload
      discussion.last_comment_at.to_s.should == comment.created_at.to_s
    end

    it 'fires a new_comment! event' do
      Events::NewComment.should_receive(:publish!)
      discussion = create(:discussion)
      comment = discussion.add_comment discussion.author, "hi"
    end
  end


  describe "destroying a comment" do
    let(:discussion) { create(:discussion) }
    context "which is the only comment on a discussion" do
      it "updates discussion.last_comment_at to discussion.created_at" do
        comment = discussion.add_comment discussion.author, "hi"
        discussion.last_comment_at.should == discussion.created_at
      end
    end
  end

  context "liked by user" do
    before do
      @like = comment.like user
    end

    it "increases like count" do
      comment.likes.count.should == 1
    end

    it "returns a CommentVote object" do
      @like.class.name.should == "CommentVote"
    end

    context "liked again by the same user" do
      before do
        comment.like user
      end

      it "does not increase like count" do
        comment.likes.count.should == 1
      end
    end
  end

  context "unliked by user" do
    before do
      comment.like user
      comment.unlike user
    end

    it "decreases like count" do
      comment.likes.count.should == 0
    end

    context "unliked again by the same user" do
      before do
        comment.unlike user
      end

      it "does not decrease like count" do
        comment.likes.count.should == 0
      end
    end
  end

  describe "#mentioned_group_members" do
    before do
      @group = create :group
      @user = create :user
      @discussion = create :discussion, :author => @user, :group => @group
      Event.stub(:send_new_comment_notifications!)
      @user.stub(:subscribed_to_mention_notifications?).and_return(true)
    end
    context "user mentions another group member" do
      before do
        @member = create :user
        @group.add_member! @member
        @comment = @discussion.add_comment @user, "@#{@member.username}"
      end
      it "returns the mentioned user" do
        @comment.mentioned_group_members.should include(@member)
      end
      it "should not return an un-mentioned user" do
        member1 = create :user
        @group.add_member! member1
        @comment.mentioned_group_members.should_not include(member1)
      end
    end
    context "user mentions a non-group member" do
      it "should not return a mentioned non-member" do
        non_member = create :user
        @comment = @discussion.add_comment @user, "@#{non_member.username}"
        @comment.mentioned_group_members.should_not include(non_member)
      end
    end
  end

  describe "#non_mentioned_discussion_participants" do
    before do
      @group = create :group
      @author = stub(:user)
      @participant = stub(:user)
      @mentioned_user = stub(:user)
      comment.stub_chain(:discussion, :participants).and_return([@participant, @author, @mentioned_user])
      comment.stub(:mentioned_group_members).and_return([@mentioned_user])
      comment.stub(:author).and_return(@author)
    end
    it "should return the the other participants" do
      comment.non_mentioned_discussion_participants.should include(@participant)
    end
    it "should not return the author" do
      comment.non_mentioned_discussion_participants.should_not include(@author)
    end
    it "should not return a mentioned user" do
      comment.non_mentioned_discussion_participants.should_not include(@mentioned_user)
    end
  end
end

