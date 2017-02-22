require 'rails_helper'

describe 'MotionService' do
  let(:group) { create(:group) }
  let(:discussion) { create :discussion, group: group }
  let(:motion) { build(:motion, discussion: discussion, author: user)}
  let(:user) { create(:user, email_on_participation: true) }
  let(:another_user) { create :user }
  let(:outcome_string) { double(:outcome_string) }
  let(:comment) { build(:comment, discussion: discussion) }
  let(:reader) { DiscussionReader.for(user: user, discussion: discussion) }

  before do
    group.add_member! user
    group.add_member! another_user
  end

  describe '#create' do

    it "authorises the action" do
      expect(user.ability).to receive(:authorize!).with(:create, motion)
      MotionService.create(motion: motion, actor: user)
    end

    it 'clears out the draft' do
      draft = create(:draft, user: user, draftable: motion.discussion, payload: { motion: { name: 'name draft' } })
      MotionService.create(motion: motion, actor: user)
      expect(draft.reload.payload['comment']).to be_blank
    end

    context "motion is valid" do

      it "saves the motion" do
        expect(motion).to receive(:save!)
        MotionService.create(motion: motion, actor: user)
      end

      it "syncs the discussion's search vector" do
        expect(SearchVector).to receive(:index!).with(motion.discussion_id)
        MotionService.create(motion: motion, actor: user)
      end

      it "enfollows the author" do
        MotionService.create(motion: motion, actor: user)
        reader = DiscussionReader.for(user: user, discussion: discussion)
        expect(reader.volume.to_sym).to eq :loud
      end

      it 'notifies new mentions' do
        motion.description = "A mention for @#{another_user.username}!"
        expect(Events::UserMentioned).to receive(:publish!).with(motion, user, another_user)
        MotionService.create(motion: motion, actor: user)
      end

      it "creates an event" do
        expect(Events::NewMotion).to receive(:publish!).with(motion)
        MotionService.create(motion: motion, actor: user)
      end

      it "returns an event" do
        expect(MotionService.create(motion: motion, actor: user)).to be_a Events::NewMotion
        MotionService.create(motion: motion, actor: user)
      end

      it 'ensures a discussion stays read' do
        CommentService.create(comment: comment, actor: another_user)
        reader = DiscussionReader.for(user: user, discussion: discussion)
        reader.viewed!(reader.discussion.last_activity_at)
        MotionService.create(motion: motion, actor: user)
        expect(reader.reload.last_read_sequence_id).to eq discussion.reload.last_sequence_id
      end

      it 'updates the discussion reader' do
        MotionService.create(motion: motion, actor: user)
        expect(reader.reload.participating).to eq true
        expect(reader.reload.volume.to_sym).to eq :loud
      end

      it "returns an event" do
        expect(MotionService.create(motion: motion, actor: user)).to be_a Events::NewMotion
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

    describe '.close' do
      before { motion.save }

      it 'stores users that did not vote' do
        MotionService.close(motion)
        expect(motion.did_not_votes.count).to eq 4
      end

      it 'sets closed_at' do
        MotionService.close(motion)
        expect(motion.reload.closed_at).to be_present
      end

      it 'fires motion closed event' do
        expect(Events::MotionClosed).to receive(:publish!).with(motion)
        MotionService.close(motion)
      end

      it "changes the discussion's salient activity count" do
        expect { MotionService.close(motion) }.to change { discussion.reload.salient_items_count }.by(1)
      end

      it 'does not mark the discussion as unread for author' do
        expect { MotionService.close(motion) }.to change { reader.reload.read_salient_items_count }.by(1)
      end
    end

    describe '.close_by_user' do

      before { motion.save }

      it 'sets closed_at' do
        MotionService.close_by_user(motion, user)
        expect(motion.closed_at).to be_present
      end

      it 'authorizes the user' do
        user.ability.should_receive(:authorize!).with(:close, motion)
        MotionService.close_by_user(motion, user)
      end

      it 'fires motion closed by user event' do
        Events::MotionClosedByUser.should_receive(:publish!).with(motion, user)
        MotionService.close_by_user(motion, user)
      end

      it "changes the discussion's salient activity count" do
        expect { MotionService.close_by_user(motion, user) }.to change { discussion.reload.salient_items_count }.by(1)
      end

      it 'does not mark the discussion as unread for author' do
        expect { MotionService.close_by_user(motion, user) }.to change { reader.reload.read_salient_items_count }.by(1)
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
      user.ability.should_receive(:authorize!).with(:create_outcome, motion)
      Events::MotionOutcomeCreated.should_receive(:publish!).with(motion)
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
      user.ability.should_receive(:authorize!).with(:update_outcome, motion)
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

  describe '.update' do
    let(:motion_params) { { description: "A mention for @#{another_user.username}" } }

    it 'notifies new mentions' do
      expect(Events::UserMentioned).to receive(:publish!).with(motion, user, another_user)
      MotionService.update(motion: motion, params: motion_params, actor: user)
    end

    it 'does not renotify old mentions' do
      expect { MotionService.update(motion: motion, params: motion_params, actor: user) }.to change { another_user.notifications.count }.by(1)
      expect { MotionService.update(motion: motion, params: motion_params, actor: user) }.to_not change  { another_user.notifications.count }
    end
  end
end
