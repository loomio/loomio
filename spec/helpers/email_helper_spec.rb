require 'rails_helper'

ENV['REPLY_HOSTNAME'] = 'replyhostname.com'

describe EmailHelper do
  context 'reply_to_address' do
    let(:discussion) { double(:discussion, key: 'd1') }
    let(:user) { double(:user, id: '1', email_api_key: 'abc123') }
    it "gives correct format" do
      output = helper.reply_to_address(discussion: discussion,
                                          user: user)
      output.should == "d=d1&u=1&k=abc123@replyhostname.com"
    end
  end
end
