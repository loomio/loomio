require_relative '../../app/services/membership_service'

module Events
  class UserAddedToGroup
  end
end

class UserMailer
  def self.delay
    self
  end
end


describe 'MembershipService' do

  let(:group){ double(:group) }
  let(:users){ [user] }
  let(:user){ double(:user) }
  let(:inviter){ double(:inviter) }
  let(:message){ double(:message) }
  let(:membership){ double(:membership, user: user, inviter: inviter, group: group) }

  describe 'add_users_to_group' do

    before do
      Events::UserAddedToGroup.stub(:publish!).with(membership, inviter)
      UserMailer.stub(:added_to_group)
      group.stub(:add_members!).and_return([membership])
    end

    after do
      MembershipService.add_users_to_group(users: users,
                                           group: group,
                                           inviter: inviter,
                                           message: message)
    end

    it 'adds the members to the group' do
      group.should_receive(:add_members!).with(users, inviter).and_return([membership])
    end

    it 'publishes the event' do
      Events::UserAddedToGroup.should_receive(:publish!).with(membership, inviter)
    end

    it 'sends the mailer' do
      UserMailer.should_receive(:added_to_group).with(user: user, inviter: inviter, group: group, message: message)
    end
  end
end