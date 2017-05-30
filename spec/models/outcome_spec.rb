require 'rails_helper'

describe Outcome do
  let(:poll) { create :poll }
  let(:outcome) { create :outcome, poll: poll }
  let(:meeting_poll) { create :poll_meeting }
  let(:meeting_outcome) { create :outcome, poll: meeting_poll, poll_option: meeting_poll.poll_options.first }

  describe 'store_calendar_invite' do
    it 'stores some ical text for meeting polls' do
      meeting_outcome.store_calendar_invite
      expect(meeting_outcome.calendar_invite).to be_present
    end

    it 'does nothing for non-meeting polls' do
      outcome.store_calendar_invite
      expect(outcome.calendar_invite).to be_nil
    end

    it 'does nothing when no poll option is set' do
      meeting_outcome.update(poll_option: nil)
      meeting_outcome.store_calendar_invite
      expect(meeting_outcome.calendar_invite).to be_nil
    end
  end
end
