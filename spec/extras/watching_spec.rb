require 'rails_helper'
describe 'watching' do

  let(:discussion) { FactoryGirl.create(:discussion) }
  let(:comment) { FactoryGirl.create(:comment, discussion: discussion) }
  let(:reply_comment) { FactoryGirl.create(:comment, discussion: discussion, parent: comment) }
  let(:motion) { FactoryGirl.build(:motion, discussion: discussion, author: motion_author) }
  let(:motion_author) { FactoryGirl.create(:user) }
  let(:vote) { FactoryGirl.create(:vote, motion: motion) }

  it 'when authoring a discussion' do
    DiscussionService.create(discussion: discussion, actor: discussion.author)
    reader = DiscussionReader.for(discussion: discussion, user: discussion.author)
    expect(reader.watching).to be true
    expect(reader.watching_reason).to eq 'new_discussion'
  end

  it 'when commenting' do
    CommentService.create(comment: comment, actor: comment.author)
    reader = DiscussionReader.for(discussion: discussion, user: comment.author)
    expect(reader.watching).to be true
    expect(reader.watching_reason).to eq 'new_comment'
  end

  it 'when someone replies to you' do
    reader = DiscussionReader.for(discussion: discussion, user: comment.author)
    expect(reader.watching).to be false

    CommentService.create(comment: reply_comment, actor: reply_comment.author)

    # check that the original comment's author is now watching
    reader = DiscussionReader.for(discussion: discussion, user: comment.author)
    expect(reader.watching).to be true
    expect(reader.watching_reason).to eq 'comment_replied_to'
  end

  it 'when someone mentions you' do
    watcher = FactoryGirl.create(:user, username: 'watcher')
    discussion.group.add_member!(watcher)
    comment.body = "hello @watcher"

    CommentService.create(comment: comment, actor: comment.author)
    reader = DiscussionReader.for(discussion: discussion, user: watcher)
    expect(reader.watching).to be true
    expect(reader.watching_reason).to eq 'user_mentioned'
  end

  it 'when you start a proposal' do
    discussion.group.add_member!(motion_author)
    MotionService.create(motion: motion, actor: motion_author)
    reader = DiscussionReader.for(discussion: discussion, user: motion.author)
    expect(reader.watching).to be true
    expect(reader.watching_reason).to eq 'new_motion'
  end

  it 'when you vote' do
    VoteService.create(vote: vote, actor: vote.author)
    reader = DiscussionReader.for(discussion: discussion, user: vote.author)
    expect(reader.watching).to be true
    expect(reader.watching_reason).to eq 'new_vote'
  end
end
