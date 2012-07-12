require 'spec_helper'

describe Comment do
  let(:user) { stub_model(User) }
  let(:discussion) { stub_model(Discussion) }
  let(:comment) { Comment.create(commentable_id: discussion.id,
                   commentable_type: 'Discussion', user_id: user.id) }

  it { should have_many(:events).dependent(:destroy) }

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

