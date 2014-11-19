require 'rails_helper'
require_relative '../../extras/discussion_headline'
include ActionView::Helpers::SanitizeHelper

describe "DiscussionHeadline" do
  let(:group) { FactoryGirl.create(:group) }
  let(:discussion_author) { FactoryGirl.create(:user, name: 'Discussion Author') }
  let(:comment_author) { FactoryGirl.create(:user, name: 'Comment Author') }
  let(:proposal_author) { FactoryGirl.create(:user, name: 'Proposal Author') }
  let(:another_author) { FactoryGirl.create(:user, name: 'Another Author') }
  let(:yet_another_author) { FactoryGirl.create(:user, name: 'Yet Another Author') }

  let(:new_motion) { FactoryGirl.create(:motion,
                                        discussion: discussion,
                                        name: "Proposal Title",
                                        author: proposal_author) }

  let(:ongoing_motion) { FactoryGirl.create(:motion,
                                            discussion: discussion,
                                            created_at: 2.days.ago,
                                            name: "Proposal Title",
                                            author: proposal_author) }

  let(:closed_motion) { FactoryGirl.create(:motion,
                                            discussion: discussion,
                                            created_at: 2.days.ago,
                                            closed_at: 1.hour.ago,
                                            name: "Proposal Title",
                                            author: proposal_author) }

  let(:discussion) { FactoryGirl.create(:discussion,
                                        group: group,
                                        author: discussion_author,
                                        title: 'Discussion Title') }

  let(:comment) { Comment.new(user: comment_author,
                              body: 'that sounds ok',
                              discussion: discussion) }

  let(:another_comment) { Comment.new(user: another_author,
                                      body: 'that sounds good',
                                      discussion: discussion) }

  let(:yet_another_comment) { Comment.new(user: yet_another_author,
                                          body: 'that sounds great',
                                          discussion: discussion) }

  let(:time_frame) { 1.day.ago...Time.now }


  before do
    group.add_member!(comment_author)
    group.add_member!(another_author)
    group.add_member!(yet_another_author)
    group.add_member!(discussion_author)
  end

  describe "discussion synopsis" do
    subject do
      strip_tags DiscussionHeadline.new(discussion, time_frame).discussion_synopsis
    end

    context "new discussion" do
      context "and no comments" do
        it {should == "Discussion Author started a discussion: Discussion Title"}
      end

      context "with 1 commenter" do

        before do
          CommentService.create(comment: comment, actor: comment_author)
        end

        it {should == "Discussion Author and Comment Author started discussing: Discussion Title"}
      end

      context "with 2 commenters" do
        before do
          CommentService.create(comment: comment, actor: comment_author)
          CommentService.create(comment: another_comment, actor: another_author)
        end
        it {should == "Discussion Author and 2 others started discussing: Discussion Title"}
      end
    end

    context "existing discussion" do
      before do
        discussion.update_attribute(:created_at, 5.days.ago)
      end

      context "with 1 commenter" do

        before do
          CommentService.create(comment: comment, actor: comment_author)
        end

        it {should == "Comment Author discussed: Discussion Title"}
      end

      context "with 2 commenters" do
        before do
          CommentService.create(comment: comment, actor: comment_author)
          CommentService.create(comment: another_comment, actor: another_author)
        end
        it {should == "Comment Author and Another Author discussed: Discussion Title"}
      end

      context "with 3 commenters" do
        before do
          CommentService.create(comment: comment, actor: comment_author)
          CommentService.create(comment: another_comment, actor: another_author)
          CommentService.create(comment: yet_another_comment, actor: yet_another_author)
        end
        it {should == "Comment Author and 2 others discussed: Discussion Title"}
      end
    end
  end

  describe "motion synopsis", focus: true do
    subject do
      strip_tags DiscussionHeadline.new(discussion, time_frame).motion_synopsis
    end

    context "new proposal" do
      before do
        new_motion
        discussion.reload
      end

      it {should == "Proposal Author proposed: Proposal Title"}
    end

    context "existing proposal with 1 new vote" do
      before do
        ongoing_motion
        Vote.create!(motion: ongoing_motion, user: another_author, position: 'yes')
      end

      it {should == "Another Author voted on: Proposal Title"}
    end

    context "existing proposal with 2 new votes" do
      before do
        ongoing_motion
        Vote.create!(motion: ongoing_motion, user: another_author, position: 'yes')
        Vote.create!(motion: ongoing_motion, user: yet_another_author, position: 'yes')
      end

      it {should == "Another Author and Yet Another Author voted on: Proposal Title"}
    end

    context "existing proposal with 3 new votes" do
      before do
        ongoing_motion
        Vote.create!(motion: ongoing_motion, user: another_author, position: 'yes')
        Vote.create!(motion: ongoing_motion, user: yet_another_author, position: 'yes')
        Vote.create!(motion: ongoing_motion, user: proposal_author, position: 'yes')
      end
      it {should == "Another Author and 2 others voted on: Proposal Title"}
    end

    context "proposal closed" do
      before do
        closed_motion.closed_at = nil
        Vote.create!(motion: closed_motion, user: another_author, position: 'yes')
        closed_motion.closed_at = 1.hour.ago
        closed_motion.save!
      end
      it {should == "Proposal Title closed with 1 participants"}
    end
  end
end
