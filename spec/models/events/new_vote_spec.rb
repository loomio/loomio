require 'spec_helper'

describe Events::NewVote do
  let(:motion) { mock_model(Motion, discussion: mock_model(Discussion)) }
  let(:vote){ mock_model(Vote, motion: motion) }

  describe "::publish!" do
    let(:event){ stub(:event, notify_users!: true) }
    before { Event.stub(:create!).and_return(event) }

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'new_vote',
                                          eventable: vote,
                                          discussion_id: vote.motion.discussion.id)
      Events::NewVote.publish!(vote)
    end

    it 'returns an event' do
      Events::NewVote.publish!(vote).should == event
    end
  end

  context "after event has been published" do
    let(:motion_author) { stub(:motion_author) }
    let(:discussion_author) { stub(:discussion_author) }
    let(:user){ mock_model(User) }
    let(:event) { Events::NewVote.new(kind: "new_vote",
                                        eventable: vote,
                                        discussion_id: vote.motion.discussion.id) }

    context 'voter is not the motion author but is the discussion author' do
      let(:vote) { mock_model(Vote, motion: motion, user: discussion_author,
                  motion_author: motion_author, discussion_author: discussion_author) }

      it 'notifies the motion author' do
        event.should_receive(:notify!).once.with(motion_author)
        event.save
      end
    end

    context 'voter is not the discussion author but is the motion author' do
      let(:vote) { mock_model(Vote, motion: motion, user: motion_author,
                  motion_author: motion_author, discussion_author: discussion_author) }

      it 'notifies the discussion author' do
        event.should_receive(:notify!).once.with(discussion_author)
        event.save
      end
    end

    context 'voter is neither the discussion author nor the motion author' do
      let(:vote) { mock_model(Vote, motion: motion, user: user,
                motion_author: motion_author, discussion_author: discussion_author) }

      it 'notifies the discussion author and the motion author' do
        event.should_receive(:notify!).with(discussion_author)
        event.should_receive(:notify!).with(motion_author)
        event.save
      end
    end

    context 'voter is the discussion author and the motion author' do
      let(:vote) { mock_model(Vote, motion: motion, user: user,
                  motion_author: user, discussion_author: user) }

      it 'notifies the discussion author' do
        event.should_not_receive(:notify!)
        event.save
      end
    end
  end
end