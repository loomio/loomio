require 'rails_helper'

describe API::AnnouncementsController do
  let(:user)  { create :user, name: 'user' }
  let(:bill)  { create :user, name: 'bill'}
  let(:member)  { create :user, name: 'member'}
  let(:group) { create :group }
  let(:another_group) { create :group, parent: group }
  let(:an_unknown_group) { create :group }

  before do
    group.add_admin! user
    sign_in user
  end

  describe 'count' do
    let(:bill)  { create :user, name: 'bill', email: 'bill@example.com'}
    let(:member)  { create :user, name: 'member'}
    let(:group) { build(:group).tap(&:save) }
    let(:discussion) { build(:discussion, group: group).tap(&:save) }

    before do
      group.add_member! member
      group.add_member! user
    end

    it 'returns a count of users who will be notified' do
      get :count, params: {recipient_emails_cmr: ['bill@example.com', 'new@example.com'].join(','),
                           recipient_user_xids: [user.id, bill.id].join('x'),
                           recipient_audience: 'group',
                           discussion_id: discussion.id}
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['count']).to eq 4
    end
  end

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
    let(:non_member) { create :user }
    let(:member) { create :user }
    let(:subgroup_member) { create :user, name: 'subgroup_member' }
    let(:subgroup) { create(:group, parent: group, name: 'subgroup') }
    let(:discussion) { create :discussion, group: group, author: user }
    let(:poll) { create :poll, group: group, author: user }

    before do
      poll.create_missing_created_event!
      discussion.create_missing_created_event!
      group.add_member!(member)
      subgroup.add_member!(subgroup_member)
      subgroup.add_member!(user)
    end

    describe 'poll' do
      describe 'as a member' do
        before do
          Membership.find_by(user_id: user.id, group_id: group.id).update(admin: false)
        end

        describe 'members_can_add_guests=false' do
          before { poll.group.update(members_can_add_guests: false) }

          it 'can add group members' do
            post :create, params: {poll_id: poll.id, recipient_user_ids: [member.id]}
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['stances'][0]['participant_id']).to eq member.id
          end

          it 'cannot invite guests' do
            post :create, params: {poll_id: poll.id, recipient_emails: ['jim@example.com']}
            expect(response.status).to eq 403
          end

          it 'cannot add subgroup members' do
            post :create, params: {poll_id: poll.id, recipient_user_ids: [subgroup_member.id]}
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['stances'].length).to eq 0
          end

          it 'cannot notify non group members' do
            post :create, params: {poll_id: poll.id, recipient_user_ids: [non_member.id]}
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['stances'].length).to eq 0
          end
        end

        describe 'members_can_add_guests=true' do
          before { poll.group.update(members_can_add_guests: true) }

          describe 'specified_voters_only=false' do
            before { poll.update(specified_voters_only: false) }

            it 'can invite guests by email' do
              post :create, params: {poll_id: poll.id, recipient_emails: ['jim@example.com']}
              expect(response.status).to eq 200
              expect(JSON.parse(response.body)['stances'].length).to eq 1
            end

            it 'can add members' do
              post :create, params: {poll_id: poll.id, recipient_user_ids: [member.id]}
              expect(response.status).to eq 200
              expect(JSON.parse(response.body)['stances'].length).to eq 1
              expect(JSON.parse(response.body)['stances'][0]['participant_id']).to eq member.id
            end

            it 'can add subgroup members' do
              post :create, params: {poll_id: poll.id, recipient_user_ids: [subgroup_member.id]}
              expect(response.status).to eq 200
              expect(JSON.parse(response.body)['stances'].length).to eq 1
              expect(JSON.parse(response.body)['stances'][0]['participant_id']).to eq subgroup_member.id
            end

            it 'cannot add unknown users' do
              post :create, params: {poll_id: poll.id, recipient_user_ids: [non_member.id]}
              expect(response.status).to eq 200
              expect(JSON.parse(response.body)['stances'].length).to eq 0
            end
          end

          describe 'specified_voters_only=true' do
            before { poll.update(specified_voters_only: true) }

            it 'cannot invite guests' do
              post :create, params: {poll_id: poll.id, recipient_emails: ['jim@example.com']}
              expect(response.status).to eq 403
            end

            it 'cannot add group members' do
              post :create, params: {poll_id: poll.id, recipient_user_ids: [member.id]}
              expect(response.status).to eq 200
              expect(JSON.parse(response.body)['stances'].length).to eq 0
            end

            it 'cannot add subgroup members' do
              post :create, params: {poll_id: poll.id, recipient_user_ids: [subgroup_member.id]}
              expect(response.status).to eq 200
              expect(JSON.parse(response.body)['stances'].length).to eq 0
            end

            it 'cannot add unknown users' do
              post :create, params: {poll_id: poll.id, recipient_user_ids: [non_member.id]}
              expect(response.status).to eq 200
              expect(JSON.parse(response.body)['stances'].length).to eq 0
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
            post :create, params: {poll_id: poll.id, recipient_audience: 'group', recipient_user_ids: [user.id]}
            expect(response.status).to eq 200
              expect(JSON.parse(response.body)['stances'].length).to eq group.members.count
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
          Membership.find_by(user_id: user.id, group_id: group.id).update(admin: true)
          poll.group.update(members_can_announce: false,
                            members_can_add_guests: false)
        end

        it 'add a group member' do
          group.add_member!(member)
          post :create, params: {poll_id: poll.id, recipient_user_ids: [member.id]}
          expect(response.status).to eq 200
          json = JSON.parse response.body
          expect(json['stances'].length).to eq 1
          expect(json['stances'][0]['participant_id']).to eq member.id
          expect(member.reload.notifications.count).to eq 1
          expect(poll.voters).to include member
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

        it 'invite non_member by email' do
          post :create, params: {poll_id: poll.id, recipient_emails: [non_member.email]}
          json = JSON.parse response.body
          expect(response.status).to eq 200
          expect(json['stances'].length).to eq 1
          json.dig(:stances, 0, :participant_id)
          expect(User.find(json['stances'].first['participant_id']).email).to eq non_member.email
          expect(poll.voters).to include non_member
        end

        it 'invite group with audience' do
          post :create, params: {poll_id: poll.id, recipient_audience: 'group', recipient_user_ids: [user.id]}
          json = JSON.parse response.body
          expect(response.status).to eq 200
          expect(json['stances'].length).to eq group.members.count
        end
      end
    end

    describe 'discussion' do
      describe 'as a member' do
        before do
          Membership.find_by(user_id: user.id, group_id: group.id).update(admin: false)
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
          Membership.find_by(user_id: user.id, group_id: group.id).update(admin: true)
          discussion.group.update(members_can_announce: false, members_can_add_guests: false)
        end

        it 'add member' do
          post :create, params: {discussion_id: discussion.id, recipient_user_ids: [member.id]}
          expect(response.status).to eq 200
          json = JSON.parse response.body
          expect(json['discussion_readers'][0]['user_id']).to eq member.id
          expect(member.notifications.count).to eq 1
          expect(discussion.readers).to include member
        end

        it 'add subgroup member' do
          post :create, params: {discussion_id: discussion.id, recipient_user_ids: [subgroup_member.id]}
          expect(response.status).to eq 200
        end

        it 'cannot add non_member' do
          post :create, params: {discussion_id: discussion.id, recipient_user_ids: [non_member.id]}
          expect(response.status).to eq 200
          expect(JSON.parse(response.body)['discussion_readers'].length).to eq 0
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

        it 'notify non_member by email' do
          post :create, params: {discussion_id: discussion.id, recipient_emails: [non_member.email]}
          json = JSON.parse response.body
          expect(response.status).to eq 200
          expect(User.where(email: non_member.email).count).to eq 1
          expect(discussion.readers).to include non_member
        end
      end
    end

    describe 'outcome' do
      let(:poll)    { create :poll, author: user, closed_at: 1.day.ago, group: group }
      let(:outcome) { create :outcome, author: user, poll: poll }

      it 'does not permit stranger to announce' do
        sign_in create(:user)
        post :create, params: {outcome_id: outcome.id, recipient_user_ids: [member.id]}
        expect(response.status).to eq 403
      end

      describe 'as a member' do
        before do
          Membership.find_by(user_id: user.id, group_id: group.id).update(admin: false)
        end

        describe 'group.members_can_add_guests=true' do
          before do
            group.update(members_can_add_guests: true)
          end

          it 'can add guests' do
            expect(User.find_by(email: "jim@example.com")).to be nil
            post :create, params: {outcome_id: outcome.id, recipient_emails: ['jim@example.com']}
            expect(response.status).to eq 200
            email_user = User.find_by(email: "jim@example.com")
            expect(email_user.notifications.count).to eq 1
            expect(email_user.email_verified).to be false
          end

          it 'can add members' do
            expect(member.notifications.count).to eq 0
            post :create, params: {outcome_id: outcome.id, recipient_user_ids: [member.id]}
            expect(response.status).to eq 200
            expect(member.notifications.count).to eq 1
          end

          it 'can add subgroup_members' do
            post :create, params: {outcome_id: outcome.id, recipient_user_ids: [subgroup_member.id]}
            expect(response.status).to eq 200
          end

          it 'cannot add non_members by id' do
            post :create, params: {outcome_id: outcome.id, recipient_user_ids: [non_member.id]}
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['users'].length).to eq 0
          end
        end

        describe 'group.members_can_add_guests=false' do
          before do
            group.update(members_can_add_guests: false)
          end

          it 'cannot add guests' do
            post :create, params: {outcome_id: outcome.id, recipient_emails: ['jim@example.com']}
            expect(response.status).to eq 403
          end

          it 'can add members' do
            post :create, params: {outcome_id: outcome.id, recipient_user_ids: [member.id]}
            expect(response.status).to eq 200
          end

          it 'cannot add subgroup_members' do
            post :create, params: {outcome_id: outcome.id, recipient_user_ids: [subgroup_member.id]}
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['users'].length).to eq 0
          end

          it 'cannot add non_members' do
            post :create, params: {outcome_id: outcome.id, recipient_user_ids: [non_member.id]}
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['users'].length).to eq 0
          end
        end

        describe 'group.members_can_announce' do
          it 'notify group' do
            group.update(members_can_announce: true)
            post :create, params: {outcome_id: outcome.id, recipient_audience: 'group'}
            expect(response.status).to eq 200
          end

          it 'cannot notify group' do
            group.update(members_can_announce: false)
            post :create, params: {outcome_id: outcome.id, recipient_audience: 'group'}
            expect(response.status).to eq 403
          end
        end
      end

      describe 'as an admin' do
        before do
          outcome.group.update(members_can_announce: false, members_can_add_guests: false)
        end

        it 'notify audience' do
          expect(member.notifications.count).to eq 0
          post :create, params: {outcome_id: outcome.id, recipient_audience: 'group'}
          expect(response.status).to eq 200
          expect(member.notifications.count).to eq 1
        end

        it 'notify member' do
          post :create, params: {outcome_id: outcome.id, recipient_user_ids: [member.id]}
          expect(response.status).to eq 200
        end

        it 'notify subgroup_member' do
          post :create, params: {outcome_id: outcome.id, recipient_user_ids: [subgroup_member.id]}
          expect(response.status).to eq 200
        end

        it 'cannot notify non_member' do
          post :create, params: {outcome_id: outcome.id, recipient_user_ids: [non_member.id]}
          expect(response.status).to eq 200
          expect(JSON.parse(response.body)['users'].length).to eq 0
        end

        it 'notify new user by email' do
          post :create, params: {outcome_id: outcome.id, recipient_emails: ['jim@example.com']}
          expect(response.status).to eq 200
          email_user = User.find_by(email: "jim@example.com")
          expect(email_user.notifications.count).to eq 1
          expect(email_user.email_verified).to be false
        end
      end
    end

    describe 'group' do
      let(:another_user) { create(:user) }
      let(:group) { create :group, creator: user}
      let(:subgroup) { create :group, parent: group, creator: user}
      let(:subgroup2) { create :group, parent: group, creator: user}
      let(:overlap_group) { create :group }

      before do
        group.add_member! member, inviter: user
      end

      describe 'members_can_add_members' do
        before do
          sign_in member
        end

        it 'allows adding members' do
          group.update(members_can_add_members: true)
          post :create, params: {group_id: group.id, recipient_emails: ['jim@example.com']}
          expect(response.status).to eq 200
        end

        it 'disallows adding members' do
          group.update(members_can_add_members: false)
          post :create, params: {group_id: group.id, recipient_emails: ['jim@example.com']}
          expect(response.status).to eq 403
        end
      end

      it 'cannot add exising user by id, if no groups in common' do
        post :create, params: {group_id: group.id, recipient_user_ids: [another_user.id]}
        expect(response.status).to eq 200 #silently ignore ids that are not allowed
        expect(another_user.notifications.count).to eq 0
        expect(another_user.memberships.count).to eq 0
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

      it 'invite to multiple groups at once' do
        subgroup.add_admin! user
        subgroup2.add_admin! user
        expect(member.memberships.accepted.count).to eq 1

        post :create, params: {group_id: group.id, recipient_user_ids: [member.id], invited_group_ids: [subgroup.id, subgroup2.id]}

        expect(response.status).to eq 200
        expect(group.members).to include(member)
        expect(member.memberships.accepted.count).to eq 3
        expect(member.memberships.pending.count).to eq 0
      end

      it 'does not invite users (by id) with no group in common' do
        post :create, params: {group_id: group.id, recipient_user_ids: [another_user.id], invited_group_ids: [group.id]}

        expect(response.status).to eq 200
        expect(another_user.notifications.count).to eq 0
        expect(another_user.memberships.pending.count).to eq 0
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
        subgroup.add_admin! user
        member.update(email_verified: false)
        post :create, params: {group_id: subgroup.id, recipient_user_ids: member.id}

        expect(response.status).to eq 200
        member.reload
        expect(member.notifications.count).to eq 1
        expect(member.memberships.accepted.count).to eq 1
        expect(subgroup.accepted_members).to_not include member
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
