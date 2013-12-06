require_relative '../../app/services/membership_service'

module Events
  class UserAddedToGroup
  end
end

describe 'MembershipService' do

  let(:group){ double(:group) }
  let(:users){ [user] }
  let(:user){ double(:user) }
  let(:inviter){ double(:inviter) }
  let(:membership){ double(:membership) }

  describe 'add_users_to_group' do

    before do
      Events::UserAddedToGroup.stub(:publish!).with(membership, inviter)
      group.stub(:add_members!).with(users, inviter).and_return([membership])
    end

    after do
      MembershipService.add_users_to_group(users: users,
                                           group: group,
                                           inviter: inviter)
    end

    it 'adds the members to the group' do
      group.should_receive(:add_members!).with(users, inviter).and_return([membership])
    end

    it 'publishes the event' do
      Events::UserAddedToGroup.should_receive(:publish!).with(membership, inviter)
    end
  end
end