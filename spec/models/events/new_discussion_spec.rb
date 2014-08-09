require 'rails_helper'

describe Events::NewDiscussion do
  let(:author) { double(:author) }
  let(:follower) { double(:follower, email_followed_threads?: true) }
  let(:discussion){ double(:discussion,
                           id: 1,
                           author: author,
                           followers_without_author: [follower]) }

  describe "::publish!" do
    let(:dr) { double(:discussion_reader, follow!: true) }
    let(:event) { double(:event, email_followers!: true) }

    before do
      allow(ThreadMailer).to receive(:new_discussion) { double(deliver: true) }
      allow(DiscussionReader).to receive(:for) { dr }

      allow(Event).to receive(:create!).
                      with(kind: 'new_discussion',
                           eventable: discussion,
                           discussion_id: discussion.id).
                      and_return(event)
    end

    it 'creates an event' do
      expect(Event).to receive(:create!).with(kind: 'new_discussion',
                                              eventable: discussion,
                                              discussion_id: discussion.id).
                                         and_return(event)
      Events::NewDiscussion.publish!(discussion)
    end

    it 'returns the event' do
      allow(Event).to receive(:create!).and_return(event)
      allow(DiscussionReader).to receive(:for) { double(follow!: true) }

      Events::NewDiscussion.publish!(discussion).should == event
    end

    it "enfollows the discussion.author" do
      expect(DiscussionReader).to receive(:for).
                                  with(discussion: discussion,
                                       user: author).and_return(dr)
      expect(dr).to receive(:follow!)
      Events::NewDiscussion.publish!(discussion)
    end

    it "emails followers of the discussion" do
      expect(ThreadMailer).to receive(:new_discussion).with(discussion, follower)
      Events::NewDiscussion.publish!(discussion)
    end
  end
end
