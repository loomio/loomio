require 'rails_helper'

describe Comment do
  let(:user) { create(:user) }
  let(:discussion) { create :discussion }
  let(:comment) { create(:comment, discussion: discussion) }
  let(:group) { create(:group) }

  describe "html sanitization" do
    it "removes script tags" do
      comment.body_format = "html"
      comment.body = "hi im a hacker <script>alert('hacked')</script>"
      expect(comment.tap(&:save).body).to eq "hi im a hacker alert('hacked')"
    end
  end

  describe "#is_most_recent?" do
    before do
      discussion.group.add_member!(user)
    end

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
    before do
      discussion.group.add_member!(user)
    end

    let(:reaction) { build :reaction, reactable: comment }
    it "destroys comment votes" do
      ReactionService.update(reaction: reaction, params: {reaction: 'smiley'}, actor: user)
      expect(Reaction.where(reactable: comment, user_id: user.id).exists?).to be true
      comment.destroy
      expect(Reaction.where(reactable: comment, user_id: user.id).exists?).to be false
    end
  end

  describe "#mentioned_users" do
    before do
      @group = create :group
      @member = create :user
      @group.add_member! @member

      # there's another group current_user belongs to, they want to mention someone from that group
      @another_group = create :group
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

      it "should not return the mentioned user" do
        comment.mentioned_users.should_not include(@another_member)
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

  describe "#mentioned audiences" do
    it "mentioning @group should return audience 'group'" do
      comment1 = create :comment, body: "@group"
      comment2 = create :comment,
                        body: "<p><span class=\"mention\" data-mention-id=\"group\" label=\"group\">@group</span></p>",
                        body_format: "html"

      expect(comment1.mentioned_audiences).to eq(['group'])
      expect(comment2.mentioned_audiences).to eq(['group'])
    end

    it "Mentioning @discussion should return audience 'discussion'" do
      comment1 = create :comment, body: "@discussion"
      comment2 = create :comment,
                        body: "<p><span class=\"mention\" data-mention-id=\"discussion\" label=\"discussion\">@discussion</span></p>",
                        body_format: "html"

      expect(comment1.mentioned_audiences).to eq(['discussion'])
      expect(comment2.mentioned_audiences).to eq(['discussion'])
    end
  end
end
