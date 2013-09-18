require 'spec_helper'

describe CommentDeleter do
  let(:discussion) { stub_model(Discussion,
                                refresh_last_comment_at: true) }
  let(:comment) { stub_model(Comment,
                             discussion: discussion,
                             destroy: true) }
  let(:comment_deleter) { CommentDeleter.new(comment) }

  describe "#delete_comment" do
    after do
      comment_deleter.delete_comment
    end

    it "destroys the comment" do
      comment.should_receive(:destroy)
    end

    it "resets discussion.last_comment_at" do
      discussion.should_receive(:refresh_last_comment_at!)
    end
  end
end
