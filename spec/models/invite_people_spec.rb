require 'spec_helper'

describe InvitePeople do
  context 'parsed_recipients' do
    it 'splits recipients string into a list of valid email strings' do
      invite_people = InvitePeople.new(:recipients => 'j@j.com, b@b.com, rob guthrie <r@g.com>')
      invite_people.parsed_recipients.should == ['j@j.com', 'b@b.com', 'rob guthrie <r@g.com>']
    end
  end
end
