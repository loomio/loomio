require_relative '../../app/services/vote_service'

module Events
  class NewVote; end
  class MotionBlocked; end
end

class MotionMailer; end

describe 'VoteService' do
  before do
    Events::NewVote.stub(:publish!)
    Events::MotionBlocked.stub(:publish!)
  end

  let(:vote) { double(:vote, position: 'yes', motion: motion, save: true, user: user)}
  let(:ability) { double(:ability, :authorize! => true) }
  let(:user) { double(:user, ability: ability) }
  let(:motion) { double(:motion) }

  describe 'cast' do
    after do
      VoteService.cast(vote)
    end

    it 'authorizes the user can vote' do
      ability.should_receive(:authorize!).with(:vote, motion)
    end

    it 'saves the vote' do
      vote.should_receive(:save).and_return(true)
    end

    context 'vote saves successfully' do
      before do
        vote.stub(:save).and_return(true)
      end

      context 'vote position is yes' do
        it 'fires the NewVote event and returns it' do
          Events::NewVote.should_receive(:publish!).with(vote)
        end
      end

      context 'vote position is block' do
        before do
          vote.stub(:position).and_return('block')
        end

        it 'fires the MotionBlocked event and returns it' do
          Events::MotionBlocked.should_receive(:publish!).with(vote)
        end
      end
    end

    context 'vote save fails' do
      before do
        vote.stub(:save).and_return(false)
      end

      it 'fires no events' do
        Events::MotionBlocked.should_not_receive(:publish!)
        Events::MotionBlocked.should_not_receive(:publish!)
      end
    end
  end
end
