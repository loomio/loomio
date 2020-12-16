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

  describe 'search for invitees to' do

    context "discussion" do
      context "without group" do
        let(:discussion) { create(:discussion, group: nil) }
        let(:poll) { create(:poll, group: nil) }

        context "as discussion admin" do
          before do
            discussion.discussion_readers.create!(user_id: actor.id, admin: true, inviter_id: actor.id)
          end

          it 'returns member of my groups' do
            get :search, params: {q: 'member', discussion_id: discussion.id}
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['users'].length).to eq 1
            expect(JSON.parse(response.body)['users'][0]['id']).to eq member.id
          end

          it 'returns guests of my threads' do
            get :search, params: {q: 'thread_guest', discussion_id: discussion.id}
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['users'].length).to eq 1
            expect(JSON.parse(response.body)['users'][0]['id']).to eq thread_guest.id
          end

          it 'returns guests of my polls' do
            get :search, params: {q: 'poll_guest', discussion_id: discussion.id}
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['users'].length).to eq 1
            expect(JSON.parse(response.body)['users'][0]['id']).to eq poll_guest.id
          end

          it 'does not return unrelated guests' do
            get :search, params: {q: 'unrelated', discussion_id: discussion.id}
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['users'].length).to eq 0
          end
        end

        context 'as discussion member' do
          it 'not returns member of my groups' do
            get :search, params: {q: 'member', discussion_id: discussion.id}
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['users'].length).to eq 0
          end

          it 'returns guests of my threads' do
            get :search, params: {q: 'thread_guest', discussion_id: discussion.id}
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['users'].length).to eq 0
          end

          it 'returns guests of my polls' do
            get :search, params: {q: 'poll_guest', discussion_id: discussion.id}
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['users'].length).to eq 0
          end

          it 'does not return unrelated guests' do
            get :search, params: {q: 'unrelated', discussion_id: discussion.id}
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['users'].length).to eq 0
          end
        end
      end

      context "in a group" do
        let(:discussion) { create(:discussion, group: group) }

        context "as group admin" do
          before { Membership.where(user: actor, group: group).update(admin: true) }
          # context members_can_add_guests is false
          it 'returns group members' do
            get :search, params: {q: 'member', discussion_id: discussion.id}
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['users'].length).to eq 1
            expect(JSON.parse(response.body)['users'][0]['id']).to eq member.id
          end

          it 'returns subgroup members' do
            get :search, params: {q: 'subgroup_member', discussion_id: discussion.id}
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['users'].length).to eq 1
            expect(JSON.parse(response.body)['users'][0]['id']).to eq subgroup_member.id
          end

          it 'does not return another organizations members' do
            get :search, params: {q: 'other_member', discussion_id: discussion.id}
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['users'].length).to eq 0
          end

          it 'does not return unrelated guests' do
            get :search, params: {q: 'guest', discussion_id: discussion.id}
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['users'].length).to eq 0
          end
        end

        context "as group member" do
          before { Membership.where(user: actor, group: group).update(admin: false) }

          context "group.members_can_add_guests=true" do
            before { group.update(members_can_add_guests: true) }

            it 'returns group members' do
              get :search, params: {q: 'member', discussion_id: discussion.id}
              expect(response.status).to eq 200
              expect(JSON.parse(response.body)['users'].length).to eq 1
              expect(JSON.parse(response.body)['users'][0]['id']).to eq member.id
            end

            it 'returns subgroup members' do
              get :search, params: {q: 'subgroup_member', discussion_id: discussion.id}
              expect(response.status).to eq 200
              expect(JSON.parse(response.body)['users'].length).to eq 1
              expect(JSON.parse(response.body)['users'][0]['id']).to eq subgroup_member.id
            end

            it 'does not return another organizations members' do
              get :search, params: {q: 'other_member', discussion_id: discussion.id}
              expect(response.status).to eq 200
              expect(JSON.parse(response.body)['users'].length).to eq 0
            end
          end

          context "group.members_can_add_guests=false" do
            before { group.update(members_can_add_guests: false) }

            it 'returns group members' do
              get :search, params: {q: 'member', discussion_id: discussion.id}
              expect(response.status).to eq 200
              expect(JSON.parse(response.body)['users'].length).to eq 1
              expect(JSON.parse(response.body)['users'][0]['id']).to eq member.id
            end

            it 'not subgroup members' do
              get :search, params: {q: 'subgroup_member', discussion_id: discussion.id}
              expect(response.status).to eq 200
              expect(JSON.parse(response.body)['users'].length).to eq 0
            end

            it 'not another organizations members' do
              get :search, params: {q: 'other_member', discussion_id: discussion.id}
              expect(response.status).to eq 200
              expect(JSON.parse(response.body)['users'].length).to eq 0
            end

            it 'does not return unrelated guests' do
              get :search, params: {q: 'unrelated', discussion_id: discussion.id}
              expect(response.status).to eq 200
              expect(JSON.parse(response.body)['users'].length).to eq 0
            end
          end
        end
      end
    end

    context "poll" do
      context "without group or discussion" do
        context "as poll admin" do
          it 'returns member of my groups' do
            get :search, params: {q: 'member', discussion_id: poll.id}
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['users'].length).to eq 1
            expect(JSON.parse(response.body)['users'][0]['id']).to eq member.id
          end

          it 'returns guests of my threads' do
            get :search, params: {q: 'thread_guest', discussion_id: poll.id}
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['users'].length).to eq 1
            expect(JSON.parse(response.body)['users'][0]['id']).to eq thread_guest.id
          end

          it 'returns guests of my polls' do
            get :search, params: {q: 'poll_guest', discussion_id: poll.id}
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['users'].length).to eq 1
            expect(JSON.parse(response.body)['users'][0]['id']).to eq poll_guest.id
          end

          it 'does not return unrelated guests' do
            get :search, params: {q: 'unrelated', discussion_id: poll.id}
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['users'].length).to eq 0
          end
        end

        context "as poll member" do
        end
      end

      context "in discussion, without group" do
        context "as discussion admin" do
          it 'returns member of actors groups'
          it 'returns guest of thread'
        end

        context "as discussion member" do
          # not sure
          # it 'does not return member of actors groups'
          # it 'does not return guest of thread'
        end
      end

      context "in group" do
        context "as group admin" do
            # context members_can_add_guests is false
            it 'returns group members'
            it 'returns subgroup members'
            it 'does not return unrelated users'
        end
        context "as group member" do
          context "group.members_can_add_guests=true" do
            it 'returns group members'
            it 'returns subgroup members'
            it 'does not return other members'
          end

          context "group.members_can_add_guests=false" do
            it 'returns group members'
            it 'does not return subgroup members'
            it 'does not return other members'
          end
        end
      end

      context "in group and discussion" do
        context "as group admin" do
            # context members_can_add_guests is false
            it 'returns group members'
            it 'returns subgroup members'
            it 'returns discussion guests'
            it 'does not return unrelated users'
          end
        end

        context "as group member, but poll admin" do
          context "group.members_can_add_guests=true" do
            it 'returns group members'
            it 'returns subgroup members'
            it 'returns discussion guests'
            it 'does not return other members'
          end

          context "group.members_can_add_guests=false" do
            it 'returns group members'
            it 'returns (existing) discussion guests'
            it 'does not return subgroup members'
            it 'does not return other members'
          end
        end
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
    let(:non_member) { create :user }
    let(:member) { create :user }
    let(:subgroup_member) { create :user }
    let(:subgroup) { create(:group, parent: group, name: 'subgroup') }
    let(:discussion) { create :discussion, group: group, author: user }
    let(:poll) { create :poll, group: group, author: user }

    before do
      poll.create_missing_created_event!
      discussion.create_missing_created_event!
      group.add_member!(member)
      subgroup.add_member!(subgroup_member)
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
            expect(response.status).to eq 403
          end

          it 'cannot notify non group members' do
            post :create, params: {poll_id: poll.id, recipient_user_ids: [non_member.id]}
            expect(response.status).to eq 403
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
              expect(response.status).to eq 403
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
              expect(response.status).to eq 403
            end

            it 'cannot add subgroup members' do
              post :create, params: {poll_id: poll.id, recipient_user_ids: [subgroup_member.id]}
              expect(response.status).to eq 403
            end

            it 'cannot add unknown users' do
              post :create, params: {poll_id: poll.id, recipient_user_ids: [non_member.id]}
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
          expect(response.status).to eq 403
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
            expect(response.status).to eq 403
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
            expect(response.status).to eq 403
          end

          it 'cannot add non_members' do
            post :create, params: {outcome_id: outcome.id, recipient_user_ids: [non_member.id]}
            expect(response.status).to eq 403
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
          expect(response.status).to eq 403
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
