require 'rails_helper'

describe API::AnnouncementsController do
  let(:user)  { create :user }
  let(:group) { create :group }
  let(:another_group) { create :group, parent: group }
  let(:an_unknown_group) { create :group }

  before do
    group.add_admin! user
    sign_in user
  end

  describe 'search' do
    let!(:a_friend)        { create :user, name: "Friendly Fran" }
    let!(:an_acquaintance) { create :user, name: "Acquaintance Annie" }
    let!(:a_stranger)      { create :user, name: "Alien Alan" }
    let(:subgroup) { create :group, parent: group}

    before do
      group.add_member! user
      group.add_member! a_friend
      another_group.add_member! user
      another_group.add_member! an_acquaintance
    end

    it 'does not return an existing user you dont know' do
      get :search, params: { q: 'alien', group_id: group.id }
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json).to be_empty
    end

    it 'returns an email address' do
      get :search, params: { q: 'bumble@bee.com', group_id: group.id }
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json[0]['name']).to eq 'bumble@bee.com'
    end

    it 'finds members in your group but not this subgroup' do
      get :search, params: { q: 'annie', group_id: group.id }
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json[0]['name']).to eq an_acquaintance.name
    end

    it 'filters out group members if a group is given' do
      get :search, params: { q: 'fran', group_id: group.id }
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json).to be_empty
    end

    it 'filters out group member email addresses' do
      get :search, params: { q: a_friend.email, group_id: group.id }
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json).to be_empty
    end

    it 'authorizes the group' do
      get :search, params: { q: 'annie', group_id: an_unknown_group.id }
      expect(response.status).to eq 403
    end
  end

  # describe 'audience' do
  #   let(:group)      { create :group }
  #   let(:discussion) { create :discussion, group: group }
  #   let(:subgroup)   { create :group, parent: group }
  #   let(:both_user)  { create :user }
  #   let(:parent_user){ create :user }
  #
  #   it 'group' do
  #     get :audience, params: {discussion_id: discussion.id, kind: "group"}
  #     expect(response.status).to eq 200
  #     json = JSON.parse response.body
  #     expect(json.map {|u| u['id']}.sort).to eq group.member_ids.sort
  #   end
  #
  #   it 'discussion_group' do
  #     guest = create :user
  #     discussion.discussion_readers.create(user: guest)
  #     get :audience, params: {discussion_id: discussion.id, kind: "discussion_group"}
  #     expect(response.status).to eq 200
  #     json = JSON.parse response.body
  #     expect(json.map {|u| u['id']}.sort).to eq Array(guest.id)
  #   end
  #
  #   it 'voters' do
  #     poll = create :poll, author: user
  #     stance = create :stance, poll: poll, cast_at: 5.minutes.ago
  #     get :audience, params: {poll_id: poll.id, kind: "voters"}
  #     expect(response.status).to eq 200
  #     json = JSON.parse response.body
  #     expect(json.map {|u| u['id']}.sort).to eq Array(stance.participant.id)
  #   end
  #
  #   it 'non_voters' do
  #     # non voters .. means has not been invited to vote, but part of the group
  #     poll = create :poll, group: group, author: user
  #     voter = create :user
  #     non_voter = create :user
  #     group.add_member! voter
  #     group.add_member! non_voter
  #     create :stance, poll: poll, participant: voter, cast_at: Time.now
  #
  #     get :audience, params: {poll_id: poll.id, kind: "non_voters"}
  #     expect(response.status).to eq 200
  #     json = JSON.parse response.body
  #     expect(json.map {|u| u['id']}.sort).to include non_voter.id
  #     expect(json.map {|u| u['id']}.sort).to_not include voter.id
  #   end
  #
  #   it 'undecided' do
  #     poll = create :poll, author: user
  #     voter = create :user
  #     undecided_voter = create :user
  #     create :stance, poll: poll, participant: voter, cast_at: Time.now
  #     create :stance, poll: poll, participant: undecided_voter
  #
  #     get :audience, params: {poll_id: poll.id, kind: "undecided_voters"}
  #     expect(response.status).to eq 200
  #     json = JSON.parse response.body
  #     expect(json.map {|u| u['id']}.sort).to include undecided_voter.id
  #     expect(json.map {|u| u['id']}.sort).to_not include voter.id
  #   end
  # end

  describe 'history' do
    let(:event) { create :event, kind: 'announcement_created', eventable: group, user: group.creator}
    let!(:notifications) { create :notification, event: event, user: user }

    it 'responds with event history' do
      sign_in user
      get :history, params: {group_id: group.id}
      expect(response.status).to eq 200
      # puts response.body
      # expect(JSON.parse response.body)

    end
  end

  describe 'announce' do
    let(:notified_user) { create :user }
    let(:member) { create :user }
    before do
      group.add_member!(notified_user)
      group.add_member!(member)
    end

    describe 'poll' do
      let(:poll)          { create :poll, group: group, author: user }
      before { poll.created_event }

      describe 'as a member' do
        before { sign_in member }

        describe 'members_can_add_guests=false' do
          before { poll.group.update(members_can_add_guests: false) }

          it 'cannot invite guests' do
            post :create, params: {poll_id: poll.id, recipient_emails: ['jim@example.com']}
            expect(response.status).to eq 403
          end

          it 'can notify individual group members' do
            post :create, params: {poll_id: poll.id, recipient_user_ids: [notified_user.id]}
            expect(response.status).to eq 200
          end
        end

        describe 'members_can_add_guests=true' do
          before { poll.group.update(members_can_add_guests: true) }

          describe 'specified_voters_only=false' do
            before { poll.update(specified_voters_only: false) }

            it 'can invite people' do
              post :create, params: {poll_id: poll.id, recipient_emails: ['jim@example.com']}
              expect(response.status).to eq 200
            end

            it 'can add indiviudal members' do
              post :create, params: {poll_id: poll.id, recipient_user_ids: [notified_user.id]}
              expect(response.status).to eq 200
            end
          end

          describe 'specified_voters_only=true' do
            before { poll.update(specified_voters_only: true) }

            it 'cannot invite people' do
              post :create, params: {poll_id: poll.id, recipient_emails: ['jim@example.com']}
              expect(response.status).to eq 403
            end

            it 'cannot add individual members' do
              post :create, params: {poll_id: poll.id, recipient_user_ids: [notified_user.id]}
              expect(response.status).to eq 403
            end
          end
        end

        describe 'members_can_announce=false' do
          before { poll.group.update(members_can_announce: false) }

          it 'prevents member from notifying group' do
            post :create, params: {poll_id: poll.id, recipient_audience: 'group'}
            expect(response.status).to eq 403
          end

          it 'allows member to notify voters' do
            # yep, you can notify existing voters
            post :create, params: {poll_id: poll.id, recipient_audience: 'voters'}
            expect(response.status).to eq 200
          end
        end

        describe 'members_can_announce=true' do
          before { poll.group.update(members_can_announce: true) }
          it 'allows member to notify group' do
            post :create, params: {poll_id: poll.id, recipient_audience: 'group'}
            expect(response.status).to eq 200
          end

          describe 'specified_voters_only=true' do
            before { poll.update(specified_voters_only: true) }
            it 'prevents member notifying group' do
              post :create, params: {poll_id: poll.id, recipient_audience: 'group'}
              expect(response.status).to eq 403
            end
          end
        end
      end

      describe 'as an admin' do
        before do
          poll.group.update(members_can_announce: false,
                            members_can_add_guests: false)
        end

        it 'invite a group member' do
          group.add_member!(notified_user)
          post :create, params: {poll_id: poll.id, recipient_user_ids: [notified_user.id]}
          expect(response.status).to eq 200
          json = JSON.parse response.body
          expect(json['stances'].length).to eq 1
          expect(json['stances'][0]['participant_id']).to eq notified_user.id
          expect(notified_user.reload.notifications.count).to eq 1
          expect(poll.voters).to include notified_user
        end

        it 'invite new user by email' do
          post :create, params: {poll_id: poll.id, recipient_emails: ['jim@example.com']}
          json = JSON.parse response.body
          expect(response.status).to eq 200
          email_user = User.find_by(email: "jim@example.com")
          json = JSON.parse response.body
          expect(json['stances'].length).to eq 1
          expect(email_user.notifications.count).to eq 1
          expect(email_user.email_verified).to be false
          expect(email_user.stances.undecided.count).to eq 1
          expect(poll.voters).to include email_user
        end

        it 'invite existing user by email' do
          post :create, params: {poll_id: poll.id, recipient_emails: [notified_user.email]}
          json = JSON.parse response.body
          expect(response.status).to eq 200
          expect(json['stances'].length).to eq 1
          json.dig(:stances, 0, :participant_id)
          expect(User.find(json['stances'].first['participant_id']).email).to eq notified_user.email
          expect(poll.voters).to include notified_user
        end

        it 'invite group with audience' do
          post :create, params: {poll_id: poll.id, recipient_audience: 'group'}
          json = JSON.parse response.body
          expect(response.status).to eq 200
          expect(json['stances'].length).to eq group.members.count
        end
      end
    end

    describe 'discussion' do
      let(:another_member) { create :user }
      let(:discussion)    { create :discussion, author: user }

      before do
        discussion.created_event
        discussion.group.add_member! member
        discussion.group.add_member! another_member
      end

      describe 'as a member' do
        before do
          sign_in member
        end

        describe 'group.members_can_add_guests' do
          it 'members can add guests' do
            discussion.group.update(members_can_add_guests: true)
            post :create, params: {discussion_id: discussion.id, recipient_emails: ['jim@example.com']}
            expect(response.status).to eq 200
          end

          it 'members cannot add guests' do
            discussion.group.update(members_can_add_guests: false)
            post :create, params: {discussion_id: discussion.id, recipient_emails: ['jim@example.com']}
            expect(response.status).to eq 403
          end
        end

        describe 'group.members_can_announce' do
          it 'members can invite audience' do
            discussion.group.update(members_can_announce: true)
            post :create, params: {discussion_id: discussion.id, recipient_audience: 'group'}
            expect(response.status).to eq 200
          end

          it 'members cannot notify group' do
            discussion.group.update(members_can_announce: false)
            post :create, params: {discussion_id: discussion.id, recipient_audience: 'group'}
            expect(response.status).to eq 403
          end
        end
      end

      describe 'as an admin' do
        before do
          sign_in user
          discussion.group.add_admin! user
          discussion.group.update(members_can_announce: false, members_can_add_guests: false)
        end

        it 'notify exising user' do
          post :create, params: {discussion_id: discussion.id, recipient_user_ids: [another_member.id]}
          expect(response.status).to eq 200
          json = JSON.parse response.body
          expect(json['discussion_readers'][0]['user_id']).to eq another_member.id
          expect(another_member.notifications.count).to eq 1
          expect(discussion.readers).to include another_member
        end

        it 'notify new user by email' do
          post :create, params: {discussion_id: discussion.id, recipient_emails: ['jim@example.com']}
          json = JSON.parse response.body
          expect(response.status).to eq 200
          email_user = User.find_by(email: "jim@example.com")
          expect(email_user.notifications.count).to eq 1
          expect(email_user.email_verified).to be false
          expect(discussion.readers).to include email_user
        end

        it 'notify existing user by email' do
          post :create, params: {discussion_id: discussion.id, recipient_emails: [notified_user.email]}
          json = JSON.parse response.body
          expect(response.status).to eq 200
          expect(User.where(email: notified_user.email).count).to eq 1
          expect(discussion.readers).to include notified_user
        end
      end
    end

    # describe 'outcome' do
    #   let(:group)   { create :group }
    #   let(:poll)    { create :poll, author: user, closed_at: 1.day.ago }
    #   let(:outcome) { create :outcome, author: user, poll: poll }
    #
    #   before do
    #     group.add_member! notified_user
    #     group.add_member! user
    #   end
    #
    #   it 'does not permit non author to announce' do
    #     sign_in create(:user)
    #     post :create, params: {outcome_id: outcome.id, recipient_user_ids: [notified_user.id]}
    #     expect(response.status).to eq 403
    #   end
    #
    #   it 'notify exising user' do
    #     post :create, params: {outcome_id: outcome.id, recipient_user_ids: [notified_user.id]}
    #     expect(response.status).to eq 200
    #     expect(notified_user.notifications.count).to eq 1
    #     # can send an outcome email but does not grant any privileges
    #   end
    #
    #   it 'notify new user by email' do
    #     post :create, params: {outcome_id: outcome.id, recipient_emails: ['jim@example.com']}
    #     expect(response.status).to eq 200
    #     email_user = User.find_by(email: "jim@example.com")
    #     expect(email_user.notifications.count).to eq 1
    #     expect(email_user.email_verified).to be false
    #     # TODO should test that an email was sent
    #   end
    #
    #   it 'notify existing user by email' do
    #     post :create, params: {outcome_id: outcome.id, recipient_emails: [notified_user.email]}
    #     expect(response.status).to eq 200
    #     expect(User.where(email: notified_user.email).count).to eq 1
    #     # TODO should test that an email was sent
    #   end
    # end

    describe 'group' do
      let(:member) { create(:user) }
      let(:group) { create :group, creator: user}
      let(:subgroup) { create :group, parent: group, creator: user}
      let(:subgroup2) { create :group, parent: group, creator: user}
      let(:overlap_group) { create :group }
      before do
        group.add_member! notified_user
      end

      describe 'members_can_add_members' do
        before do
          group.add_member! member
          sign_in member
        end

        it 'allows inviting members' do
          group.update(members_can_add_members: true)
          post :create, params: {group_id: group.id, recipient_emails: ['jim@example.com']}
          expect(response.status).to eq 200
        end

        it 'disallows inviting members' do
          group.update(members_can_add_members: false)
          post :create, params: {group_id: group.id, recipient_emails: ['jim@example.com']}
          expect(response.status).to eq 403
        end
      end

      it 'notify exising user' do
        post :create, params: {group_id: group.id, recipient_user_ids: [notified_user.id]}
        expect(response.status).to eq 200
        expect(notified_user.notifications.count).to eq 1
        expect(group.members).to include notified_user
      end

      it 'notify new user by email' do
        post :create, params: {group_id: group.id, recipient_emails: ['jim@example.com']}
        expect(response.status).to eq 200
        email_user = User.find_by(email: "jim@example.com")
        expect(email_user.notifications.count).to eq 1
        expect(email_user.email_verified).to be false
        expect(email_user.memberships.pending.count).to eq 1
        expect(group.members).to include email_user
      end

      it 'supports inviting to multiple groups at once' do
        group.add_member! member, inviter: user
        subgroup.add_admin! user
        subgroup2.add_admin! user
        expect(member.memberships.accepted.count).to eq 1

        post :create, params: {group_id: group.id, recipient_user_ids: member.id, invited_group_ids: [subgroup.id, subgroup2.id]}

        expect(response.status).to eq 200
        expect(group.members).to include(member)
        expect(member.memberships.accepted.count).to eq 3
        expect(member.memberships.pending.count).to eq 0
      end

      it 'supports inviting to multiple auto accepting subgroups' do
        member.memberships.delete_all
        overlap_group.add_member!(member)
        overlap_group.add_member!(user)
        subgroup.add_admin! user
        expect(member.memberships.accepted.count).to eq 1
        post :create, params: {group_id: group.id, recipient_user_ids: [member.id], invited_group_ids: [group.id, subgroup.id]}

        expect(response.status).to eq 200
        expect(member.notifications.count).to eq 1
        expect(member.memberships.pending.count).to eq 2
      end

      it 'auto accepts subgroup invitiations to existing members' do
        group.add_member! member
        subgroup.add_admin! user
        expect(member.memberships.accepted.count).to eq 1
        post :create, params: {group_id: subgroup.id, recipient_user_ids: member.id}

        expect(response.status).to eq 200
        member.reload
        expect(member.notifications.count).to eq 1
        expect(member.memberships.accepted.count).to eq 2
        expect(subgroup.accepted_members).to include member
      end

      it 'does not auto accept subgroup invitiations to not accepted members' do
        membership = group.add_member! member
        membership.update(accepted_at: nil)
        subgroup.add_admin! user
        post :create, params: {group_id: subgroup.id, recipient_user_ids: member.id}

        expect(response.status).to eq 200
        member.reload
        expect(member.notifications.count).to eq 1
        expect(member.memberships.count).to eq 2
        expect(member.memberships.accepted.count).to eq 0
        expect(subgroup.accepted_members).to_not include member
      end

      it 'does not auto accept subgroup invitiations to unverified users' do
        group.add_member! member
        subgroup.add_admin! user
        member.update(email_verified: false)
        post :create, params: {group_id: subgroup.id, recipient_user_ids: member.id}

        expect(response.status).to eq 200
        member.reload
        expect(member.notifications.count).to eq 1
        expect(member.memberships.accepted.count).to eq 1
        expect(subgroup.accepted_members).to_not include member
      end

      it 'notify existing user by email' do
        post :create, params: {group_id: group.id, recipient_emails: [notified_user.email]}
        expect(response.status).to eq 200
        expect(User.where(email: notified_user.email).count).to eq 1
        expect(notified_user.groups).to include group
      end

      it 'does not allow announcement if max members is reached' do
        AppConfig.app_features[:subscription] = true
        Subscription.for(group).update(max_members: 0)
        post :create, params: {group_id: group.id, recipient_emails: ['jim@example.com']}
        expect(response.status).to eq 403
      end
    end
  end
end
