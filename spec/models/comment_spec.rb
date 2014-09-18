require 'rails_helper'

describe Comment do
  let(:user) { FactoryGirl.create :user }
  let(:discussion) { FactoryGirl.create :discussion }
  let(:comment) { FactoryGirl.create(:comment, discussion: discussion) }

  #describe 'parent_comment_belongs_to_same_discussion' do
    #let(:comment) { FactoryGirl.build(:comment, discussion: discussion) }
    #let(:comment_save_discussion) { FactoryGirl.create(:comment, discussion: discussion) }
    #let(:comment_other_discussion) { FactoryGirl.create(:comment) }

    #before { comment.save }

    #subject { comment }

    #context 'no parent' do
      #it {should have(0).errors_on(:parent) }
    #end

    #context 'parent belongs to same discussion' do
      #before do
        #comment.parent = comment_save_discussion
      #end

      #it {should have(0).errors_on(:parent) }
    #end

    #context 'parent belongs to another discussion' do
      #before do
        #comment.parent = comment_other_discussion
      #end

      #it {should have(1).errors_on(:parent) }
    #end
  #end

  describe "#is_most_recent?", focus: true do
    subject { comment.is_most_recent? }
    context "comment is the last one added to discussion" do
      it { should be true }
    end
    context "a newer comment exists" do
      before do
        comment
        DiscussionService.add_comment(build :comment, discussion: discussion)
      end
      it { should be false }
    end
  end

  describe "#destroy" do
    it "calls discussion.commented_deleted!" do
      discussion.should_receive(:comment_deleted!)
      comment.destroy
    end
  end

  describe "validate attachments_owned_by_author" do
    it "raises error if author does not own attachments" do
      attachment = create(:attachment)
      comment.attachments << attachment
      comment.save
      comment.should have(1).errors_on(:attachments)
    end
  end

  context "liked by user" do
    before do
      @like = comment.like user
      comment.reload
    end

    it "increases like count" do
      comment.comment_votes.count.should == 1
    end

    it "returns a CommentVote object" do
      @like.class.name.should == "CommentVote"
    end

    context "liked again by the same user" do
      before do
        comment.like user
      end

      it "does not increase like count" do
        comment.comment_votes.count.should == 1
      end
    end
  end

  context "unliked by user" do
    before do
      comment.like user
      comment.unlike user
    end

    it "decreases like count" do
      comment.comment_votes.count.should == 0
    end

    context "unliked again by the same user" do
      before do
        comment.unlike user
      end

      it "does not decrease like count" do
        comment.comment_votes.count.should == 0
      end
    end
  end

  describe "#mentioned_group_members" do
    before do
      @group = create :group
      @member = create :user
      @group.add_member! @member
      @discussion = create :discussion, group: @group
    end

    context "user mentions another group member" do
      let(:comment) { create :comment, discussion: @discussion, body: "@#{@member.username}" }

      it "returns the mentioned user" do
        comment.mentioned_group_members.should include(@member)
      end
    end

    context "user mentions a non-group member" do
      let(:non_member) { create :user }
      let(:comment) { create :comment, discussion: @discussion, body: "@#{non_member.username}" }

      it "should not return a mentioned non-member" do
        non_member = create :user
        comment.mentioned_group_members.should_not include(non_member)
      end
    end
  end

  describe "#non_mentioned_discussion_participants" do
    before do
      @group = create :group
      @author = double(:user)
      @participant = double(:user)
      @mentioned_user = double(:user)
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

