require_relative '../../app/services/motion_service'

module Events
  class MotionOutcomeCreated
  end
  class MotionOutcomeUpdated
  end
  class MotionClosed
  end
  class MotionClosedByUser
  end
  class MotionBlocked
  end
  class NewVote
  end
end

class Motion
end

describe 'MotionService' do
  let(:group) { double(:group, present?: true) }
  let(:motion) { double(:motion, outcome: "", group: group, :outcome= => true, :outcome_author= => true, :save! => true, save: true) }
  let(:ability) { double(:ability, :authorize! => true) }
  let(:user) { double(:user, ability: ability) }
  let(:motion_params) { {outcome: "We won!"} }
  let(:outcome_string) { double(:outcome_string) }
  let(:event) { double(:event) }


  before do
    Events::MotionOutcomeCreated.stub(:publish!).and_return(event)
    Events::MotionOutcomeUpdated.stub(:publish!).and_return(event)
  end

  describe '.cast_vote' do
    let(:vote) { double(:vote, motion: motion, user: user, save: false) }

    it "authorizes the action" do
      ability.should_receive(:authorize!).with(:vote, motion)
      MotionService.cast_vote(vote)
    end

    context 'vote is valid' do
      after do
        MotionService.cast_vote(vote)
      end

      before do
        vote.should_receive(:save).and_return(true)
      end

      context 'position is block' do
        before do
          vote.stub(:is_block?).and_return(true)
          vote.stub(:previous_position_is_block?).and_return(false)
        end
        it 'fires motion blocked event' do
          Events::MotionBlocked.should_receive(:publish!).with(vote)
        end

        context 'previous position of user was block' do
          before do
            vote.stub(:previous_position_is_block?).and_return(true)
          end
          it 'does not fire motion blocked event' do
            Events::MotionBlocked.should_not_receive(:publish!)
          end
        end
      end

      context 'position is not block' do
        before do
          vote.stub(:is_block?).and_return(false)
        end

        it 'fires a new vote event' do
          Events::NewVote.should_receive(:publish!).with(vote)
        end
      end
    end

    context 'vote is invalid' do
      before do
        vote.should_receive(:save).and_return false
      end

      it 'returns nil' do
        MotionService.cast_vote(vote).should == nil
      end
    end
  end

  describe '.close_lapsed_motions' do
    it 'closes lapsed but not closed motions' do
      lapsed_motions = [motion]
      Motion.should_receive(:lapsed_but_not_closed).and_return(lapsed_motions)
      MotionService.should_receive(:close).with(motion)
      MotionService.close_all_lapsed_motions
    end
  end

  describe 'closing the motion' do
    before do
      Events::MotionClosed.stub(:publish!)
      Events::MotionClosedByUser.stub(:publish!)
      motion.stub(:closed_at=)
      motion.stub(:save!)
      motion.stub(:store_users_that_didnt_vote)
    end

    describe '.close' do
      after { MotionService.close(motion) }

      it 'stores users that did not vote' do
        motion.should_receive(:store_users_that_didnt_vote)
      end

      it 'sets closed_at' do
        motion.should_receive(:closed_at=)
      end

      it 'saves the motion' do
        motion.should_receive(:save!)
      end

      it 'fires motion closed event' do
        Events::MotionClosed.should_receive(:publish!).with(motion)
      end
    end

    describe '.close_by_user' do
      after { MotionService.close_by_user(motion, user) }

      it 'stores users that did not vote' do
        motion.should_receive(:store_users_that_didnt_vote)
      end

      it 'sets closed_at' do
        motion.should_receive(:closed_at=)
      end

      it 'saves the motion' do
        motion.should_receive(:save!)
      end

      it 'authorizes the user' do
        ability.should_receive(:authorize!).with(:close, motion)
      end

      it 'fires motion closed by user event' do
        Events::MotionClosedByUser.should_receive(:publish!).with(motion, user)
      end
    end
  end

  describe '.create_outcome' do
    it 'authorizes the user can set the outcome' do
      ability.should_receive(:authorize!).with(:create_outcome, motion)
      MotionService.create_outcome(motion, motion_params, user)
    end

    it 'updates the outcome and outcome_author attributes' do
      motion.should_receive(:outcome=).with(motion_params[:outcome])
      motion.should_receive(:outcome_author=).with(user)
      motion.should_receive(:save)
      MotionService.create_outcome(motion, motion_params, user)
    end

    it 'creates a motion_outcome_created event' do
      Events::MotionOutcomeCreated.should_receive(:publish!).with(motion, user)
      MotionService.create_outcome(motion, motion_params, user)
    end

    context 'outcome is invalid' do
      before do
        motion.stub(:save).and_return false
      end

      it 'returns false' do
        MotionService.create_outcome(motion, motion_params, user).should == false
      end

      it 'does not create an event' do
        Events::MotionOutcomeCreated.should_not_receive(:publish!)
        MotionService.create_outcome(motion, motion_params, user)
      end
    end
  end

  describe '.update_outcome' do
    it 'authorizes the user can set the outcome' do
      ability.should_receive(:authorize!).with(:update_outcome, motion)
      MotionService.update_outcome(motion, motion_params, user)
    end

    it 'updates the outcome and outcome_author attributes' do
      motion.should_receive(:outcome=).with(motion_params[:outcome])
      motion.should_receive(:outcome_author=).with(user)
      motion.should_receive(:save)
      MotionService.update_outcome(motion, motion_params, user)
    end

    it 'creates a motion_outcome_updated event' do
      Events::MotionOutcomeUpdated.should_receive(:publish!).with(motion, user)
      MotionService.update_outcome(motion, motion_params, user)
    end

    context 'outcome is invalid' do
      before do
        motion.stub(:save).and_return false
      end

      it 'returns false' do
        MotionService.update_outcome(motion, motion_params, user).should == false
      end

      it 'does not create an event' do
        Events::MotionOutcomeUpdated.should_not_receive(:publish!)
        MotionService.update_outcome(motion, motion_params, user)
      end
    end
  end
end
