require 'rails_helper'

describe InvitePeopleForm do
  context 'parsed_emails' do
    it 'splits recipients string into a list of valid email strings' do
      invite_people = InvitePeopleForm.new(:recipients => 'j@j.com, b@b.com, rob guthrie <r@g.com>')
      invite_people.instance_eval{ parsed_emails } .should == ['j@j.com', 'b@b.com', 'rob guthrie <r@g.com>']
    end
  end
end
