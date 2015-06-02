require 'rails_helper'

describe 'MotionService' do
  let(:group) { double(:group, present?: true) }
  let(:discussion) { double :discussion, id: 1 }
  let(:motion) { double :motion,
                        discussion: discussion,
                        discussion_id: discussion.id,
                        outcome: "",
                        author: user,
                        'author=' => true,
                        group: group,
                        valid?: true,
                        :outcome= => true,
                        :outcome_author= => true,
                        :save! => true }
  let(:ability) { double(:ability, :authorize! => true) }
  let(:user) { double(:user, ability: ability) }
  let(:outcome_string) { double(:outcome_string) }
  let(:event) { double(:event) }
  let(:discussion_reader) { double :discussion_reader, set_volume_as_required!: true }


  before do
    allow(DiscussionReader).to receive(:for) { discussion_reader }
    Events::MotionOutcomeCreated.stub(:publish!) { event }
    Events::MotionOutcomeUpdated.stub(:publish!) { event }
  end

  describe '#create', focus: true do
    before do
      allow(Events::NewMotion).to receive(:publish!)
    end

    after do
      MotionService.create(motion: motion, actor: user)
    end

    it "authorises the action" do
      expect(ability).to receive(:authorize!).with(:create, motion)
    end

    context "motion is valid" do

      before do
        allow(motion).to receive(:valid?) { true }
        allow(Events::NewMotion).to receive(:publish!) {event}
      end

      it "saves the motion" do
        expect(motion).to receive(:save!)
      end

      it "syncs the discussion's search vector" do
        expect(ThreadSearchService).to receive(:index!).with(motion.discussion_id)
      end

      it "enfollows the author" do
        expect(discussion_reader).to receive(:set_volume_as_required!) {true}
      end

      it "creates an event" do
        expect(Events::NewMotion).to receive(:publish!).with(motion)
      end

      it "returns an event" do 
        expect(MotionService.create(motion: motion, actor: user)).to be event
      end
    end

    context "motion is invalid" do
      before { allow(motion).to receive(:valid?) {false}}

      it "returns false" do
        expect(MotionService.create(motion: motion, actor: user)).to be false
      end

      it "does not save the motion" do
        expect(motion).to_not receive(:save!)
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

  describe 'reopen' do
    let(:date) { 2.days.from_now }
    let(:did_not_votes) { double(:did_not_votes) }

    before do
      motion.stub(:closing_at=)
      motion.stub(:closed_at=)
      motion.stub(:did_not_votes).and_return(did_not_votes)
      did_not_votes.stub(:delete_all)
    end

    after { MotionService.reopen(motion, date) }

    it 'clears the closed_at' do
      motion.should_receive(:closed_at=).with(nil)
    end

    it 'sets a new closing_at' do
      motion.should_receive(:closing_at=).with(date)
    end

    it 'clears did not votes' do
      did_not_votes.should_receive(:delete_all)
    end
  end

  describe '.create_outcome' do
    before do
      motion.stub(:outcome_author)
      allow(motion).to receive(:outcome_author) { user }
      allow(motion).to receive(:outcome) { "Agreement and engagement" }
    end

    it 'authorizes the user can set the outcome' do
      ability.should_receive(:authorize!).with(:create_outcome, motion)
      motion.should_receive(:save!)
      Events::MotionOutcomeCreated.should_receive(:publish!).with(motion, user)
      MotionService.create_outcome(motion: motion, params: {}, actor: user)
    end

    context 'outcome is invalid' do
      before do
        motion.stub(:valid?).and_return false
      end

      it 'returns false' do
        expect(MotionService.create_outcome(motion: motion, params: {}, actor: user)).to be false
      end

      it 'does not create an event' do
        Events::MotionOutcomeCreated.should_not_receive(:publish!)
        MotionService.create_outcome(motion: motion, params: {}, actor: user)
      end
    end
  end
  describe '.update_outcome' do
    before do
      motion.stub(:outcome_author)
      allow(motion).to receive(:outcome_author) { user }
      allow(motion).to receive(:outcome) { "Updated agreement and engagement" }
    end

    it 'authorizes the user can update the outcome' do
      ability.should_receive(:authorize!).with(:update_outcome, motion)
      motion.should_receive(:save!)
      Events::MotionOutcomeUpdated.should_receive(:publish!).with(motion, user)
      MotionService.update_outcome(motion: motion, params: {}, actor: user)
    end

    context 'outcome is invalid' do
      before do
        motion.stub(:valid?).and_return false
      end

      it 'returns false' do
        expect(MotionService.update_outcome(motion: motion, params: {}, actor: user)).to be false
      end

      it 'does not update an event' do
        Events::MotionOutcomeUpdated.should_not_receive(:publish!)
        MotionService.update_outcome(motion: motion, params: {}, actor: user)
      end
    end
  end
end
