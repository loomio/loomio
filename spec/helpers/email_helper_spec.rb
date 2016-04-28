require 'rails_helper'

ENV['REPLY_HOSTNAME'] = 'replyhostname.com'

describe EmailHelper do
  context 'reply_to_address' do
    let(:discussion) { double(:discussion, id: 'd1') }
    let(:user) { double(:user, id: '1', email_api_key: 'abc123') }
    it "gives correct format" do
      output = helper.reply_to_address(discussion: discussion,
                                          user: user)
      expect(output).to eq "d=d1&u=1&k=abc123@replyhostname.com"
    end
  end

  describe 'time_formatted_relative_to_age' do
    let(:time){ Time.parse "2013-01-02 16:55:00 UTC" }

    subject do
      helper.time_formatted_relative_to_age(time)
    end

    context 'when time is same day' do
      it 'displays hours, minutes and meridian' do
        Timecop.freeze("2013-01-02 12:00:00 UTC") do
          expect(subject).to eq ' 4:55 pm'
        end
      end
    end

    context 'when it is not the same day' do
      it 'displays date only' do
        Timecop.freeze("2013-01-01 12:00:00 UTC") do
          expect(subject).to eq ' 2 Jan'
        end
      end
    end

    context 'when it is not the same year' do
      it 'displays date and year' do
        Timecop.freeze("2014-01-01 12:00:00 UTC") do
          expect(subject).to eq '2/1/13'
        end
      end
    end
  end
end
