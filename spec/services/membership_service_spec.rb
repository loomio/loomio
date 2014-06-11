require_relative '../../app/services/membership_service'

module Events
  class UserAddedToGroup
  end

  class UserJoinedGroup
    def self.publish!(membership)
    end
  end
end

class UserMailer
  def self.delay
    self
  end
end


describe 'MembershipService' do

  let(:users){ [user] }
  let(:user){ double(:user, ability: ability) }
  let(:inviter){ double(:inviter) }
  let(:message){ double(:message) }
  let(:ability){ double(:ability, authorize!: true) }

  describe 'join_group' do
    let(:group){ double(:group, add_member!: membership) }
    let(:membership){ double(:membership) }
    after do
      MembershipService.join_group(user: user, group: group)
    end

    it "authorises the action" do
      ability.should_receive(:authorize!).with(:join, group)
    end

    it "adds the member to the group" do
      group.should_receive(:add_member!).with(user).and_return(membership)
    end

    it "publishes the joined group event" do
      Events::UserJoinedGroup.should_receive(:publish!).with(membership)
    end
  end

  describe 'add_users_to_group' do
    let(:group){ double(:group) }
    let(:membership){ double(:membership, user: user, inviter: inviter, group: group) }

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
