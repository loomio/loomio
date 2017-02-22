require 'rails_helper'

describe Events::UserAddedToGroup do
  let(:membership){ create :membership }
  let(:memberships) { [create(:membership), create(:membership)] }
  let(:inviter) { create :user }

  describe "::publish!(membership, inviter)" do

    it 'creates an event' do
      expect { Events::UserAddedToGroup.publish!(membership, inviter) }.to change { Event.where(kind: 'user_added_to_group').count }.by(1)
    end

    it 'returns an event' do
      expect(Events::UserAddedToGroup.publish!(membership, inviter)).to be_a Event
    end

    it 'sends an email' do
      expect(UserMailer).to receive(:user_added_to_group).and_return(OpenStruct.new(deliver: nil))
      Events::UserAddedToGroup.publish!(membership, inviter)
    end
  end

  describe "::bulk_publish!" do
    it 'creates multiple events' do
      expect { Events::UserAddedToGroup.bulk_publish!(memberships, inviter) }.to change { Event.where(kind: 'user_added_to_group').count }.by(memberships.length)
    end

    it 'returns multiple events' do
      result = Events::UserAddedToGroup.bulk_publish!(memberships, inviter)
      expect(result).to be_a Array
      expect(result[0]).to be_a Event
    end

    it 'sends emails' do
      expect { Events::UserAddedToGroup.bulk_publish!(memberships, inviter) }.to change { ActionMailer::Base.deliveries.count }.by(2)
    end
  end
end
