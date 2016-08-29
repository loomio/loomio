require 'rails_helper'

describe ProposalsClosingSoonJob do
  let!(:motion) { create :motion, closing_at: 24.hours.from_now }
  let(:user)  { create :user }
  let(:discussion) { create :discussion }
  let(:unsaved_motion) { build :motion, author: user, discussion: discussion, closing_at: 24.hours.from_now }
  let(:subject) { ProposalsClosingSoonJob.new.perform }

  describe 'perform' do
    it 'publishes a proposal closing soon event' do
      expect { subject }.to change { Event.where(kind: :motion_closing_soon).count }.by(1)
    end

    it 'does not publish multiple motion_closing_soon events' do
      discussion.group.add_member! user
      MotionService.create(motion: unsaved_motion, actor: user)
      unsaved_motion.reload

      MotionService.update(motion: unsaved_motion, params: { closing_at: 2.days.from_now.to_s }, actor: unsaved_motion.author)
      expect { ProposalsClosingSoonJob.new.perform }.to_not change { unsaved_motion.author.notifications.count }
      Timecop.travel(1.day.from_now)

      expect { ProposalsClosingSoonJob.new.perform }.to change { unsaved_motion.author.notifications.count }.by(1)
      MotionService.update(motion: unsaved_motion, params: { closing_at: 4.days.from_now.to_s }, actor: unsaved_motion.author)
      expect { ProposalsClosingSoonJob.new.perform }.to_not change { unsaved_motion.author.notifications.count }

      Timecop.travel(3.days.from_now)
      expect { ProposalsClosingSoonJob.new.perform }.to change { unsaved_motion.author.notifications.count }.by(1)
    end

    it 'does not publish a motion_closing_soon event for a closed motion' do
      motion.update(closed_at: 2.hours.ago)
      expect { subject }.to_not change { Event.where(kind: :motion_closing_soon).count }
    end

    it 'does not publish a motion_closing_soon event for motions closing in more 24 hours' do
      motion.update(closing_at: 30.hours.from_now)
      expect { subject }.to_not change { Event.where(kind: :motion_closing_soon).count }
    end

    it 'does not publish an event if one has been published already in the past 24 hours' do
      Events::MotionClosingSoon.publish!(motion)
      expect { subject }.to_not change { Event.where(kind: :motion_closing_soon).count }
    end

    it 'publishes an event if the existing motion_closing_soon event is stale' do
      event = Events::MotionClosingSoon.publish!(motion)
      event.update(created_at: 3.days.ago)
      expect { subject }.to change { Event.where(kind: :motion_closing_soon).count }.by(1)
    end
  end
end
