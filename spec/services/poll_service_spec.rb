require 'rails_helper'

describe PollService do
  let(:poll_created) { build :poll, discussion: discussion }
  let(:public_poll) { build :poll }
  let(:private_poll) { build :poll }
  let(:poll) { create :poll, discussion: discussion }
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:visitor) { LoggedOutUser.new }
  let(:group) { create :formal_group }
  let(:another_group) { create :formal_group }

  let(:discussion) { create :discussion, group: group }
  let(:stance) { create :stance, poll: poll_created, choice: poll_created.poll_options.first.name }
  let(:identity) { create :slack_identity }

  before { group.add_member!(user) }

  describe '#convert_visitors' do
    # convert visitors with stances to unverified users
    # convert visitors without stances to invitaitons for open polls
    it 'converts visitors with stances to unverified users' do
      visitor = Visitor.new(name: "joe", email: 'joe@example.com')
      community = poll.community_of_type(:email, build: true)
      community.visitors << visitor
      community.save
      visitor.reload
      stance = create :stance, poll: poll, participant: visitor
      expect { PollService.convert_visitors(poll: poll)}.to change {poll.guest_group.members.count}.by(1)
      expect(poll.guest_group.members.count).to eq 1
      user = poll.guest_group.members.first
      expect(stance.reload.participant).to eq user
    end

    it 'converts visitors without stances to invitations' do
      visitor = Visitor.new(name: "joe", email: 'joe@example.com')
      community = poll.community_of_type(:email, build: true)
      community.visitors << visitor
      community.save
      visitor.reload
      poll.save
      expect { PollService.convert_visitors(poll: poll)}.to_not change {poll.guest_group.members.count}
      expect(poll.guest_group.reload.invitations.count).to eq 1
      invitation = poll.guest_group.invitations.first
      expect(invitation.recipient_email).to eq visitor.email
    end
  end

  describe '#create' do
    it 'creates a new poll' do
      expect { PollService.create(poll: poll_created, actor: user) }.to change { Poll.count }.by(1)
    end

    it 'populates removing custom poll actions' do
      poll_created.poll_type = 'poll'
      poll_created.poll_options = []
      poll_created.poll_option_names = ["green"]
      expect { PollService.create(poll: poll_created, actor: user) }.to change { Poll.count }.by(1)

      expect(poll_created.reload.poll_options.count).to eq 1
      expect(poll_created.poll_options.first.name).to eq "green"
    end

    it 'does not allow adding custom proposal actions' do
      poll_created.poll_type = 'proposal'
      poll_created.poll_option_names = ["superagree"]
      expect { PollService.create(poll: poll_created, actor: user) }.to_not change { Poll.count }
    end

    it 'does not create an invalid poll' do
      poll_created.title = ''
      expect { PollService.create(poll: poll_created, actor: user) }.to_not change { Poll.count }
    end

    it 'does not allow logged out users to create polls' do
      expect { PollService.create(poll: poll_created, actor: logged_out_user) }.to raise_error { CanCan::AccessDenied }
    end

    it 'does not allow users to create polls they are not allowed to' do
      expect { PollService.create(poll: poll_created, actor: another_user) }.to raise_error { CanCan::AccessDenied }
    end

    describe 'announcements' do
      it 'announces the poll to a group' do
        poll_created.make_announcement = true
        expect { PollService.create(poll: poll_created, actor: user) }.to change { ActionMailer::Base.deliveries.count }.by(poll_created.group.members.count - 1)
      end

      it 'does not announce unless make_announcement is set to true' do
        expect { PollService.create(poll: poll_created, actor: user) }.to_not change { ActionMailer::Base.deliveries.count }
      end

      # it 'does not announce if a group is not specified' do
      #   poll_created.make_announcement = true
      #   expect { PollService.create(poll: poll_created, actor: user) }.to_not change { ActionMailer::Base.deliveries.count }
      # end
    end

  end

  describe '#update' do
    before { PollService.create(poll: poll_created, actor: user) }

    it 'updates an existing poll' do
      PollService.update(poll: poll_created, params: { details: "A new description" }, actor: user)
      expect(poll_created.reload.details).to eq "A new description"
    end

    it 'does not allow randos to edit proposals' do
      expect { PollService.update(poll: poll_created, params: { details: "A new description" }, actor: another) }.to raise_error { CanCan::AccessDenied }
      expect(poll_created.reload.details).to_not eq "A new description"
    end

    it 'does not save an invalid poll' do
      old_title = poll_created.title
      PollService.update(poll: poll_created, params: { title: "" }, actor: user)
      expect(poll_created.reload.title).to eq old_title
    end

    it 'makes an announcement to participants if make_announcement is true' do
      stance
      expect {
        PollService.update(poll: poll_created, params: { details: "A new description", make_announcement: true }, actor: user)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'creates a new poll edited event for poll option changes' do
      expect {
        PollService.update(poll: poll_created, params: { poll_option_names: ["new_option"] }, actor: user)
      }.to change { Events::PollEdited.where(kind: :poll_edited).count }.by(1)
    end

    it 'creates a new poll edited event for major changes' do
      expect {
        PollService.update(poll: poll_created, params: { title: "BIG CHANGES!" }, actor: user)
      }.to change { Events::PollEdited.where(kind: :poll_edited).count }.by(1)
    end

    it 'does not create a new poll edited event for minor changes' do
      expect {
        PollService.update(poll: poll_created, params: { anyone_can_participate: false }, actor: user)
      }.to_not change { Events::PollEdited.where(kind: :poll_edited).count }
    end
  end

  describe 'add_options' do
    before { poll.update(voter_can_add_options: true) }

    it 'adds new poll options' do
      expect {
        PollService.add_options(poll: poll, params: { poll_option_names: ['new_option'] }, actor: user)
      }.to change { poll.poll_options.count }.by(1)
      expect(poll.reload.poll_option_names).to include 'new_option'
      expect(Event.last.kind).to eq 'poll_option_added'
    end

    it 'does not update when poll does not accept new options' do
      poll.update(voter_can_add_options: false)
      expect {
        PollService.add_options(poll: poll, params: { poll_option_names: ['new_option'] }, actor: user)
      }.to raise_error { CanCan::AccessDenied }
      expect(poll.reload.poll_option_names).to_not include 'new_option'
      expect(Event.last).to be_nil
    end

    it 'does not update when no new options are passed' do
      expect {
        PollService.add_options(poll: poll, params: { poll_option_names: [] }, actor: user)
      }.to_not change { Event.count }
    end

    it 'does not update for unauthorized user' do
      expect {
        PollService.add_options(poll: poll, params: { poll_option_names: ['new_option'] }, actor: another_user)
      }.to raise_error { CanCan::AccessDenied }
    end
  end

  describe 'close' do
    it 'closes a poll' do
      PollService.create(poll: poll_created, actor: user)
      PollService.close(poll: poll_created, actor: user)
      expect(poll_created.reload.closed_at).to be_present
    end

    it 'disallows the creation of new stances' do
      PollService.create(poll: poll_created, actor: user)
      stance_created = build(:stance, poll: poll_created)
      expect(user.ability.can?(:create, stance_created)).to eq true
      PollService.close(poll: poll_created, actor: user)
      expect(user.ability.can?(:create, stance_created)).to eq false
    end

    it 'creates poll_did_not_votes for each member that did not vote' do
      formal_user = create :user
      guest_user = create :user
      PollService.create(poll: poll_created, actor: user)
      poll_created.group.add_member! formal_user
      poll_created.guest_group.add_member! guest_user
      PollService.close(poll: poll_created, actor: user)
      expect(poll_created.reload.poll_did_not_voters).to include(formal_user, guest_user)
    end
  end

  describe 'expire_lapsed_polls' do
    it 'expires a lapsed poll' do
      PollService.create(poll: poll_created, actor: user)
      poll_created.update_attribute(:closing_at,1.day.ago)
      PollService.expire_lapsed_polls
      expect(poll_created.reload.closed_at).to be_present
    end

    it 'does not expire active poll' do
      PollService.create(poll: poll_created, actor: user)
      PollService.expire_lapsed_polls
      expect(poll_created.reload.closed_at).to_not be_present
    end

    it 'does not touch closed polls' do
      PollService.create(poll: poll_created, actor: user)
      poll_created.update_attributes(closing_at: 1.day.ago, closed_at: 1.day.ago)
      expect { PollService.expire_lapsed_polls }.to_not change { poll_created.reload.closed_at }
    end
  end

  describe '#toggle_subscription' do
    it 'toggles a subscription on' do
      PollService.toggle_subscription(poll: poll, actor: user)
      expect(poll.reload.unsubscribers).to include user
    end

    it 'toggles a subscription off' do
      poll.unsubscribers << user
      PollService.toggle_subscription(poll: poll, actor: user)
      expect(poll.reload.unsubscribers).to_not include user
    end

    it 'does nothing if the user doesnt have access' do
      expect { PollService.toggle_subscription(poll: poll, actor: another_user) }.to raise_error { CanCan::AccessDenied }
    end
  end

  describe '#cleanup_examples' do
    it 'removes example polls' do
      create(:poll, example: true, created_at: 2.days.ago)
      expect { PollService.cleanup_examples }.to change { Poll.count }.by(-1)
    end

    it 'does not remove recent example polls' do
      create(:poll, example: true, created_at: 30.minutes.ago)
      expect { PollService.cleanup_examples }.to_not change { Poll.count }
    end

    it 'does not remove non-example polls' do
      create(:poll, created_at: 2.days.ago)
      expect { PollService.cleanup_examples }.to_not change { Poll.count }
    end
  end
end
