require 'rails_helper'

describe Events::NewComment do
  let(:discussion_author)  { double(:discussion_author) }
  let(:comment_author)     { double(:comment_author) }
  let(:mentioned_user)     { double(:mentioned_user) }
  let(:discussion)         { double(:discussion,
                                    id: 1,
                                    author: discussion_author) }

  let(:comment)            { double :comment,
                                    author: comment_author,
                                    discussion: discussion,
                                    mentioned_group_members: [mentioned_user],
                                    followers_without_author: followers_double }

  let(:followers_double)   { double :followers_double,
                                    email_followed_threads: [follower] }

  let(:follower)           { double :follower }
  let(:discussion_reader)  { double(:discussion_reader, follow!: true) }
  let(:mailer)             { double deliver: true }

  before do
    allow(DiscussionReader).to receive(:for) { discussion_reader }
    allow(Events::UserMentioned).to receive(:publish!)
    allow(ThreadMailer).to receive(:new_comment) { mailer }
  end

  describe "::publish!" do
    let(:event) { double(:event, notify_users!: true) }
    before { Event.stub(:create!).and_return(event) }

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'new_comment',
                                          eventable: comment,
                                          discussion_id: comment.discussion.id)
      Events::NewComment.publish!(comment)
    end

    it 'returns an event' do
      Events::NewComment.publish!(comment).should == event
    end

    it 'enfollows the author' do
      expect(DiscussionReader).to receive(:for).
                                  with(discussion: discussion,
                                       user: comment_author) { double follow!: true }

      Events::NewComment.publish!(comment)
    end

    it 'creates mention events' do
      expect(comment).to receive(:mentioned_group_members) { [mentioned_user] }
      expect(Events::UserMentioned).to receive(:publish!).with(comment, mentioned_user)
      Events::NewComment.publish!(comment)
    end

    it 'emails discussion followers but not comment author' do
      expect(ThreadMailer).to receive(:new_comment).with(comment, follower)
      Events::NewComment.publish!(comment)
    end
  end
end
