require 'rails_helper'

describe MembershipRequest do
  let(:group) { create(:group) }
  let(:membership_request) { build(:membership_request, group: group, requestor: build(:user)) }
  let(:long_introduction) { "h#{'i' * 400}!"}
  let(:responder) { stub_model User }
  let(:requestor) { create(:user) }

  describe 'introduction length' do
    it 'validates length on create' do
      membership_request.introduction = long_introduction
      expect(membership_request.valid?).to eq false
    end

    it 'does not validate length on update' do
      membership_request.save
      expect(membership_request.update(introduction: long_introduction)).to eq true
    end
  end

  context 'user' do
    it 'cannot have multiple pending requests' do
      membership_request = MembershipRequest.new(introduction: 'hi')
      membership_request.requestor = requestor
      membership_request.group = group
      membership_request.save!

      membership_request_2 = MembershipRequest.new(introduction: 'hi again')
      membership_request_2.requestor = requestor
      membership_request_2.group = group
      membership_request_2.save
      membership_request_2.should have(1).errors_on(:requestor)
      membership_request_2.should have(0).errors_on(:email)
    end

    it 'can make new requests when there are old responded-to requests' do
      membership_request = MembershipRequest.new(introduction: 'hi')
      membership_request.requestor = requestor
      membership_request.group = group
      membership_request.response = 'approved'
      membership_request.responder = responder
      membership_request.save!

      membership_request_2 = MembershipRequest.new(introduction: 'hi again')
      membership_request_2.requestor = requestor
      membership_request_2.group = group
      membership_request_2.save
      membership_request_2.should have(0).errors_on(:requestor)
    end

    it 'cannot request membership if already a member' do
      group.add_member!(requestor)
      membership_request = MembershipRequest.new(introduction: 'hi')
      membership_request.requestor = requestor
      membership_request.group = group
      membership_request.save

      membership_request.should have(1).errors_on(:requestor)
      membership_request.should have(0).errors_on(:email)
    end
  end

  describe '#approve!(responder)' do
    before do
      membership_request.approve!(responder)
    end
    it "sets response to approved" do
      expect(membership_request.response).to eq 'approved'
    end
    it "sets responder" do
      expect(membership_request.responder).to eq responder
    end
    it "sets response_at" do
      membership_request.responded_at.should_not be_blank
    end
  end
end
