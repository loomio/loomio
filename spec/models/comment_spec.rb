require 'spec_helper'

describe Comment do
  let(:user) { stub_model(User) }
  let(:discussion) { stub_model(Discussion) }
  let(:comment) { Comment.create(commentable_id: discussion.id,
                   commentable_type: 'Discussion', user_id: user.id) }

  it { should have_many(:events).dependent(:destroy) }

  describe "creating a comment on a discussion" do
    it "updates discussion.last_comment_at" do
      discussion = create_discussion
      comment = discussion.add_comment discussion.author, "hi"
      discussion.reload
      discussion.last_comment_at.to_s.should == comment.created_at.to_s
    end
  end

  describe "destroying a comment" do
    let(:discussion) { create_discussion }

    context "which is the only comment on a discussion" do
      it "updates discussion.last_comment_at to discussion.created_at" do
        comment = discussion.add_comment discussion.author, "hi"
        discussion.last_comment_at.should == discussion.created_at
      end
    end

    context "which is the most recent comment on a discussion" do
      it "updates discussion.last_comment_at to the previous comment" do
        comment1 = discussion.add_comment discussion.author, "hi"
        comment2 = discussion.add_comment discussion.author, "hi"
        comment2.destroy
        discussion.reload
        discussion.last_comment_at.to_s.should == comment1.created_at.to_s
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
end

