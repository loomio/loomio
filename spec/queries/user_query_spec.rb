require 'rails_helper'

describe UserQuery do
  let!(:poll) { create :poll, group: nil, discussion: nil }
  let!(:group) { create(:group, name: 'group') }
  let!(:subgroup) { create(:group, parent: group, name: 'subgroup') }
  let!(:subgroup_member) { create(:user, name: 'subgroup_member') }
  let!(:discussion) { create(:discussion, group: nil) }
  let!(:other_discussion) { create(:discussion, title: 'other discussion', group: nil) }
  let!(:other_group) { create(:group, name: 'other_group') }
  let!(:other_poll) { create :poll, title: 'other poll', group: nil, discussion: nil }
  let!(:member) { create(:user, name: 'member') }
  let!(:other_member) { create(:user, name: 'other_member') }
  let!(:thread_guest) { create(:user, name: 'thread_guest') }
  let!(:poll_guest) { create(:user, name: 'poll_guest') }
  let!(:actor) { create(:user, name: 'actor') }
  let!(:unrelated) { create(:user, name: 'unrelated') }

  before do
    group.add_member! actor
    group.add_member! member
    subgroup.add_member! actor
    subgroup.add_member! subgroup_member
    other_group.add_member! actor
    other_group.add_member! other_member
    discussion.discussion_readers.create!(user_id: actor.id, admin: true, inviter_id: actor.id)
    other_discussion.discussion_readers.create!(user_id: actor.id, admin: true, inviter_id: actor.id)
    other_discussion.discussion_readers.create!(user_id: thread_guest.id, inviter_id: actor.id)
    poll.stances.create!(participant_id: actor.id, inviter_id: actor.id, admin: true)
    poll.stances.create!(participant_id: poll_guest.id, inviter_id: actor.id)
  end

  context "invitable_to" do
    context "discussion" do
      context "without group" do
        before { discussion.update(group_id: nil) }

        context "as discussion admin" do
          it 'returns members of my groups' do
            expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'member').count).to eq 1
            expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'member').first.id).to eq member.id
          end

          it 'returns guests of my threads' do
            expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'thread_guest').count).to eq 1
            expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'thread_guest').first.id).to eq thread_guest.id
          end

          it 'returns guests of my polls' do
            expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'poll_guest').count).to eq 1
            expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'poll_guest').first.id).to eq poll_guest.id
          end

          it 'does not return unrelated users' do
            expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'unrelated').count).to eq 0
          end
        end

        context 'as discussion member' do
          before do
            discussion.discussion_readers.where(user_id: actor.id).update_all(admin: false)
          end

          it 'returns no members of my groups' do
            expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'member').count).to eq 0
          end

          it 'returns no guests of my threads' do
            expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'thread_guest').count).to eq 0
          end

          it 'returns no guests of my polls' do
            expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'poll_guest').count).to eq 0
          end

          it 'returns no unrelated users' do
            expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'unrelated').count).to eq 0
          end
        end
      end

      context "in a group" do
        let(:discussion) { create(:discussion, group: group) }

        context "as group admin" do
          before { Membership.where(user: actor, group: group).update(admin: true) }
          # context members_can_add_guests is false
          it 'returns group members' do
            expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'member').count).to eq 1
            expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'member').first.id).to eq member.id
          end

          it 'returns subgroup members' do
            expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'subgroup_member').count).to eq 1
            expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'subgroup_member').first.id).to eq subgroup_member.id
          end

          it 'does not return another organizations members' do
            expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'other_member').count).to eq 0
          end

          it 'does not return unrelated users' do
            expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'unrelated').count).to eq 0
          end
        end

        context "as group member" do
          before { Membership.where(user: actor, group: group).update(admin: false) }

          context "group.members_can_add_guests=true" do
            before { group.update(members_can_add_guests: true) }

            it 'returns group members' do
              expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'member').count).to eq 1
              expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'member').first.id).to eq member.id
            end

            it 'returns subgroup members' do
              expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'subgroup_member').count).to eq 1
              expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'subgroup_member').first.id).to eq subgroup_member.id
            end

            it 'does not return another organizations members' do
              expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'other_member').count).to eq 0
            end

            it 'does not return unrelated users' do
              expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'unrelated').count).to eq 0
            end
          end

          context "group.members_can_add_guests=false" do
            before { group.update(members_can_add_guests: false) }

            it 'returns group members' do
              expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'member').count).to eq 1
              expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'member').first.id).to eq member.id
            end

            it 'does not return subgroup members' do
              expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'subgroup_member').count).to eq 0
            end

            it 'does not return another organizations members' do
              expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'other_member').count).to eq 0
            end

            it 'does not return unrelated guests' do
              expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'unrelated').count).to eq 0
            end
          end
        end
      end
    end

    context "poll" do
      context "without group or discussion" do
        let(:poll) { create(:poll, group: nil, discussion: nil) }
        context "as poll admin" do
          before { poll.stances.where(participant_id: actor.id).update_all(admin: true, inviter_id: actor.id) }

          it 'returns members of my groups' do
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'member').count).to eq 1
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'member').first.id).to eq member.id
          end

          it 'returns guests of my threads' do
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'thread_guest').count).to eq 1
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'thread_guest').first.id).to eq thread_guest.id
          end

          it 'returns guests of my polls' do
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'poll_guest').count).to eq 1
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'poll_guest').first.id).to eq poll_guest.id
          end

          it 'does not return unrelated users' do
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'unrelated').count).to eq 0
          end
        end

        context "as poll member" do
          before { poll.stances.where(participant_id: actor.id).update_all(admin: false, inviter_id: actor.id) }

          it 'returns no members of my groups' do
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'member').count).to eq 0
          end

          it 'returns no guests of my threads' do
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'thread_guest').count).to eq 0
          end

          it 'returns no guests of my polls' do
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'poll_guest').count).to eq 0
          end

          it 'returns no unrelated users' do
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'unrelated').count).to eq 0
          end
        end
      end

      context "in discussion, without group" do
        before { poll.update(discussion_id: discussion.id, group_id: nil) }

        context "as discussion admin" do
          before { discussion.discussion_readers.where(user_id: actor.id).update_all(admin: true) }

          it 'returns members of my groups' do
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'member').count).to eq 1
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'member').first.id).to eq member.id
          end

          it 'returns guests of my threads' do
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'thread_guest').count).to eq 1
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'thread_guest').first.id).to eq thread_guest.id
          end

          it 'returns guests of my polls' do
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'poll_guest').count).to eq 1
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'poll_guest').first.id).to eq poll_guest.id
          end

          it 'does not return unrelated users' do
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'unrelated').count).to eq 0
          end
        end

        context "as discussion member" do
          before { discussion.discussion_readers.where(user_id: actor.id).update_all(admin: false) }

          it 'returns no members of my groups' do
            expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'member').count).to eq 0
          end

          it 'returns no guests of my threads' do
            expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'thread_guest').count).to eq 0
          end

          it 'returns no guests of my polls' do
            expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'poll_guest').count).to eq 0
          end

          it 'returns no unrelated users' do
            expect(UserQuery.invitable_to(model: discussion, actor: actor, q: 'unrelated').count).to eq 0
          end
        end
      end

      context "in group" do
        before { poll.update(group: group) }

        context "as group admin" do
          before { Membership.where(user: actor, group: group).update(admin: true) }
          # context members_can_add_guests is false
          it 'returns group members' do
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'member').count).to eq 1
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'member').first.id).to eq member.id
          end

          it 'returns subgroup members' do
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'subgroup_member').count).to eq 1
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'subgroup_member').first.id).to eq subgroup_member.id
          end

          it 'does not return another organizations members' do
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'other_member').count).to eq 0
          end

          it 'does not return unrelated users' do
            expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'unrelated').count).to eq 0
          end
        end

        context "as group member" do
          before { Membership.where(user: actor, group: group).update(admin: false) }

          context "group.members_can_add_guests=true" do
            before { group.update(members_can_add_guests: true) }

            it 'returns group members' do
              expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'member').count).to eq 1
              expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'member').first.id).to eq member.id
            end

            it 'returns subgroup members' do
              expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'subgroup_member').count).to eq 1
              expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'subgroup_member').first.id).to eq subgroup_member.id
            end

            it 'does not return another organizations members' do
              expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'other_member').count).to eq 0
            end

            it 'does not return unrelated users' do
              expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'unrelated').count).to eq 0
            end
          end

          context "group.members_can_add_guests=false" do
            before { group.update(members_can_add_guests: false) }

            it 'returns group members' do
              expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'member').count).to eq 1
              expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'member').first.id).to eq member.id
            end

            it 'does not return subgroup members' do
              expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'subgroup_member').count).to eq 0
            end

            it 'does not return another organizations members' do
              expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'other_member').count).to eq 0
            end

            it 'does not return unrelated guests' do
              expect(UserQuery.invitable_to(model: poll, actor: actor, q: 'unrelated').count).to eq 0
            end
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
  end
end
