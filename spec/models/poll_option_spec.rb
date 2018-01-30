require 'rails_helper'

describe PollOption do
  describe 'display_name' do

    describe 'normal poll' do
      let(:poll_option) { build :poll_option, poll: build(:poll) }
      it 'returns the humanized option name' do
        poll_option.name = "letsdoit!"
        expect(poll_option.display_name).to eq "Letsdoit!"
      end
    end

    describe 'dates_as_options poll' do
      let(:poll_option) { build :poll_option, poll: build(:poll_meeting) }

      it 'returns the correct datetime' do
        poll_option.name = "#{Date.today.year}-01-01T10:00:00.000Z"
        expect(poll_option.display_name(zone: "UTC")).to match /1 Jan 10:00 am/
      end

      it 'returns the correct datetime with year when year is different' do
        poll_option.name = "2016-01-01T10:00:00.000Z"
        expect(poll_option.display_name(zone: "UTC")).to eq "Fri 1 Jan 2016 10:00 am"
      end

      it 'returns the correct date' do
        poll_option.name = "#{Date.today.year}-01-01"
        expect(poll_option.display_name(zone: "UTC")).to match /1 Jan/
      end

      it 'returns the correct date with year when year is different' do
        poll_option.name = "2016-01-01"
        expect(poll_option.display_name(zone: "UTC")).to eq "Fri 1 Jan 2016"
      end
    end
  end
end
