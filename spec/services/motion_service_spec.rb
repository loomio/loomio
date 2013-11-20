require_relative '../../app/services/motion_service'

module Events
  class MotionOutcomeCreated
  end
  class MotionOutcomeUpdated
  end
  class MotionClosed
  end
end

class Motion
end

describe 'MotionService' do
  let(:group) { double(:group, present?: true) }
  let(:motion) { double(:motion, update_attribute: true, outcome: "", group: group) }
  let(:ability) { double(:ability, :authorize! => true) }
  let(:user) { double(:user, ability: ability) }
  let(:motion_params) { {outcome: "We won!"} }
  let(:outcome_string) { double(:outcome_string) }
  let(:event) { double(:event) }


  before do
    Events::MotionOutcomeCreated.stub(:publish!).and_return(event)
    Events::MotionOutcomeUpdated.stub(:publish!).and_return(event)
  end

  describe '.close_lapsed_motions' do
    it 'closes lapsed but not closed motions' do
      lapsed_motions = [motion]
      Motion.should_receive(:lapsed_but_not_closed).and_return(lapsed_motions)
      MotionService.should_receive(:close).with(motion)
      MotionService.close_all_lapsed_motions
    end
  end

  describe '.close' do
    before do
      Events::MotionClosed.stub(:publish!)
      motion.stub(:closed_at=)
      motion.stub(:save!)
      motion.stub(:store_users_that_didnt_vote)
    end

    after do
      MotionService.close(motion, user)
    end
    
    it 'stores users that did not vote' do
      motion.should_receive(:store_users_that_didnt_vote)
    end

    it 'sets closed_at' do
      motion.should_receive(:closed_at=)
    end

    it 'fires motion closed event' do
      Events::MotionClosed.should_receive(:publish!).with(motion, user)
    end

    it 'saves the motion' do
      motion.should_receive(:save!)
      MotionService.close(motion)
    end
  end

  describe '.create_outcome' do
    it 'authorizes the user can set the outcome' do
      ability.should_receive(:authorize!).with(:create_outcome, motion)
      MotionService.create_outcome(motion, motion_params, user)
    end

    it 'updates the motion outcome attribute' do
      motion.should_receive(:update_attribute).with(:outcome, motion_params[:outcome])
      MotionService.create_outcome(motion, motion_params, user)
    end

    it 'creates a motion_outcome_created event' do
      Events::MotionOutcomeCreated.should_receive(:publish!).with(motion, user)
      MotionService.create_outcome(motion, motion_params, user)
    end

    context 'outcome is invalid' do
      before do
        motion.stub(:update_attribute).and_return false
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

    it 'updates the motion outcome attribute' do
      motion.should_receive(:update_attribute).with(:outcome, motion_params[:outcome])
      MotionService.update_outcome(motion, motion_params, user)
    end

    it 'creates a motion_outcome_updated event' do
      Events::MotionOutcomeUpdated.should_receive(:publish!).with(motion, user)
      MotionService.update_outcome(motion, motion_params, user)
    end

    context 'outcome is invalid' do
      before do
        motion.stub(:update_attribute).and_return false
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
