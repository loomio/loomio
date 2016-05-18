require 'rails_helper'

describe ProposalsClosingSoonJob do
  let!(:motion) { create :motion, closing_at: 24.hours.from_now }
  let(:subject) { ProposalsClosingSoonJob.new.perform }

  describe 'perform' do
    it 'publishes a proposal closing soon event' do
      expect { subject }.to change { Event.where(kind: :motion_closing_soon).count }.by(1)
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
