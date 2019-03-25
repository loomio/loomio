require 'rails_helper'

describe Comment do
  let(:user) { create(:user) }
  let(:discussion) { create :discussion }
  let(:comment) { create(:comment, discussion: discussion) }

  before do
    discussion.group.add_member!(user)
  end

  describe "sanitization" do
    it "removes script tags" do
      comment.body = "hi im a hacker <script>alert('hacked')</script>"
      expect(comment.body).to eq "hi im a hacker alert('hacked')"
    end
  end

  describe "#is_most_recent?" do
    subject { comment.is_most_recent? }
    context "comment is the last one added to discussion" do
      it { should be true }
    end
    context "a newer comment exists" do
      before do
        comment
        CommentService.create(comment: build(:comment, discussion: discussion), actor: user)
      end
      it { should be false }
    end
  end

  describe "#destroy" do
    let(:reaction) { build :reaction, reactable: comment }
    it "destroys comment votes" do
      ReactionService.update(reaction: reaction, params: {reaction: 'smiley'}, actor: user)
      expect(Reaction.where(reactable: comment, user_id: user.id).exists?).to be true
      comment.destroy
      expect(Reaction.where(reactable: comment, user_id: user.id).exists?).to be false
    end
  end

  describe "validate documents_owned_by_author" do
    it "raises error if author does not own documents" do
      document = create(:document)
      comment.documents << document
      comment.save
      comment.should have(1).errors_on(:documents)
    end
  end

  describe "#mentioned_users" do
    before do
      @group = create :formal_group
      @member = create :user
      @group.add_member! @member

      # there's another group current_user belongs to, they want to mention someone from that group
      @another_group = create :formal_group
      @another_member = create :user
      @another_group.add_member! @another_member
      @another_group.add_member! user

      @discussion = create :discussion, group: @group
    end

    context "user mentions a group member" do
      let(:comment) { create :comment, discussion: @discussion, body: "@#{@member.username}" }

      it "returns the mentioned user" do
        comment.mentioned_users.should include(@member)
      end
    end

    context "user mentions a member of another group they belong to" do
      let(:comment) { create :comment, author: user, discussion: @discussion, body: "@#{@another_member.username}" }

      it "returns the mentioned user" do
        comment.mentioned_users.should include(@another_member)
      end
    end

    context "user mentions a non-group member" do
      let(:non_member) { create :user }
      let(:comment) { create :comment, discussion: @discussion, body: "@#{non_member.username}" }

      it "should not return a mentioned non-member" do
        non_member = create :user
        comment.mentioned_users.should_not include(non_member)
      end
    end
  end
end
