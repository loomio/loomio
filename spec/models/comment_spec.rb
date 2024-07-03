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

  describe "#mentioned collection" do
    let(:discussion) { create :discussion, group: group }

    def group_members
      group.all_members.humans
    end

    def thread_members
      User.joins(:discussion_readers)
          .where("discussion_readers.discussion_id = ?", discussion.id)
    end

    def mentioned_members_ids(comment)
      mentioned = comment.mentioned_users.pluck(:id)
    end

    def difference(a, b)
      a.size > b.size ? a - b : b - a
    end

    before do
      4.times { group.add_member!(create :user) }
      thread_members = group_members[..(group_members.size/2)]
      thread_members.each { |m| discussion.add_guest!(m, nil) }
    end

    it "mentioning @group should return all users except the author of the group" do
      comment = create :comment, discussion:, body: "@group"
      group_members_ids = group_members.where.not('users.id': comment.author.id).pluck(:id)

      expect(difference(group_members_ids, mentioned_members_ids(comment))).to eq([])
    end

    it "Mentioning @thread should return all users except the author of the discussion" do
      comment = create :comment, discussion:, body: "@thread"

      expect(difference(thread_members.pluck(:id), mentioned_members_ids(comment))).to eq([])
    end

    it "mentioning @thread and non-thread user should return all thread users except the author and the mentioned user" do
      non_thread_users = group_members - thread_members
      mentioned_users = thread_members.to_a << non_thread_users.first
      comment = create :comment, discussion:, body: "@thread @#{mentioned_users.last.username}"

      expect(difference(mentioned_users.pluck(:id), mentioned_members_ids(comment))).to eq([])
    end
  end
end
