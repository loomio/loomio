require 'rails_helper'

# Isolated style
describe Events::NewDiscussion do
  let(:author) { double(:author) }
  let(:discussion){ double(:discussion, author: author, id: 1) }

  describe "::publish!" do
    let(:event) { double(:event) }
    let(:dr) { double(:discussion_reader, follow!: true) }

    before do
      Event.stub(:create!).and_return(event)
      DiscussionReader.stub(:for).and_return(dr)
    end

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'new_discussion',
                                          eventable: discussion,
                                          discussion_id: discussion.id)
      Events::NewDiscussion.publish!(discussion)
    end

    it 'returns the event' do
      Events::NewDiscussion.publish!(discussion).should == event
    end

    it "enfollows the discussion.author" do
      expect(DiscussionReader).to receive(:for).with(discussion: discussion,
                                                     user: user).and_return(dr)
      expect(dr).to receive(:follow!)
    end

    it "emails followers of the discussion" do
      expect(ThreadMailer).to receive(:new_discussion).with(discussion, follower)
    end
  end
end
