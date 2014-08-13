require 'rails_helper'

describe Events::UserMentioned do
  describe "::publish!" do
    let(:discussion) { double :discussion }
    let(:comment) { double :comment, discussion: discussion }
    let(:mentioned_user) { double :user, email_when_mentioned?: false  }
    let(:discussion_reader) { double :discussion_reader, following?: false, follow!: true }
    let(:event) { double :event }

    before do
      allow(DiscussionReader).to receive(:for) { discussion_reader }
      allow(Events::UserMentioned).to receive(:create!) { event }
      allow(event).to receive(:notify!)
    end

    after do
      Events::UserMentioned.publish!(comment, mentioned_user)
    end

    it 'creates an event' do
      expect(Events::UserMentioned).to receive(:create!).with(kind: 'user_mentioned',
                                                              eventable: comment,
                                                              user: mentioned_user)
    end

    it 'returns an event' do
      Events::UserMentioned.publish!(comment, mentioned_user).should == event
    end

    it "enfollows the user" do
      expect(discussion_reader).to receive(:follow!)
    end

    it "creates an in-app mentioned notification" do
      expect(event).to receive(:notify!).with(mentioned_user)
    end
  end
end
