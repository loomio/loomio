require 'rails_helper'

describe UserQuery do
  let!(:poll) { create :poll, group: nil, discussion: nil }
  let!(:group) { build(:group, name: 'group').tap(&:save) }
  let!(:subgroup) { build(:group, parent: group, name: 'subgroup').tap(&:save) }
  let!(:subgroup_member) { create(:user, name: 'subgroup_member') }
  let!(:discussion) { build(:discussion, group: nil).tap(&:save)  }
  let!(:other_discussion) { build(:discussion, title: 'other discussion', group: nil).tap(&:save) }
  let!(:other_group) { build(:group, name: 'other_group').tap(&:save) }
  let!(:other_poll) { create :poll, title: 'other poll', group: nil, discussion: nil }
  let!(:member) { create(:user, name: 'member') }
  let!(:other_member) { create(:user, name: 'other_member') }
  let!(:thread_guest) { create(:user, name: 'thread_guest') }
  let!(:other_guest) { create(:user, name: 'other_guest') }
  let!(:poll_guest) { create(:user, name: 'poll_guest') }
  let!(:actor) { create(:user, name: 'actor') }
  let!(:unrelated) { create(:user, name: 'unrelated') }
  let!(:invited) { create(:user, name: 'invited') }
  let!(:inviter) { create(:user, name: 'inviter') }

  before do
    group.add_member! actor
    group.add_member! member
    subgroup.add_member! actor
    subgroup.add_member! subgroup_member
    other_group.add_member! actor
    other_group.add_member! other_member
    discussion.discussion_readers.create!(user_id: actor.id, inviter_id: inviter.id)
    discussion.discussion_readers.create!(user_id: thread_guest.id, inviter_id: inviter.id)
    other_discussion.discussion_readers.create!(user_id: actor.id, inviter_id: inviter.id)
    other_discussion.discussion_readers.create!(user_id: other_guest.id, inviter_id: inviter.id)
    other_discussion.discussion_readers.create!(user_id: invited.id, inviter_id: actor.id)
    poll.stances.create!(participant_id: actor.id, inviter_id: actor.id)
    poll.stances.create!(participant_id: poll_guest.id, inviter_id: inviter.id)
  end

  context "invitable_search" do
    subject do
      UserQuery.invitable_search(model: nil, actor: actor).pluck(:name)
    end

    context "nil model" do
      it "returns members of actors groups, actors inviter and invited" do
        expect(subject).to include *[member, subgroup_member, other_member, invited, inviter].map(&:name)
      end

      it 'does not include guests from other models' do
        expect(subject).not_to include *[poll_guest, thread_guest].map(&:name)
      end
    end

    context "discussion (with a poll)" do
      before do
        poll.update(discussion: discussion)
      end

      subject do
        UserQuery.invitable_search(model: discussion, actor: actor).pluck(:name)
      end

      context "without group" do
        context "as admin" do
          before do
            DiscussionReader.where(discussion_id: discussion.id, user_id: actor.id).update_all(admin: true)
          end

          it 'returns actors group members, inviters and invited' do
            expect(subject).to include *[member, subgroup_member, other_member, thread_guest, poll_guest, inviter, invited].map(&:name)
            expect(subject).not_to include unrelated.name
          end
        end

        context "as member" do
          it 'returns thread_guest, poll_guest' do
            expect(subject).to include *[thread_guest, poll_guest, actor].map(&:name)
            expect(subject.count).to eq 3
          end
        end
      end

      context "in a group" do
        before do
          discussion.update(group_id: group.id)
        end

        context "as group admin" do
          before { Membership.where(user: actor, group: group).update(admin: true) }

          it 'returns group, subgroup members, thread guests, poll_guests' do
            expect(subject).to include *[member, subgroup_member, thread_guest, poll_guest, inviter, invited].map(&:name)
          end

          it 'excludes other org members, unrelated users' do
            expect(subject).not_to include *[other_member, unrelated].map(&:name)
          end
        end

        context "as group member" do
          before { Membership.where(user: actor, group: group).update(admin: false) }

          context "group.members_can_add_guests=true" do
            before { group.update(members_can_add_guests: true) }

            it 'returns group & subgroup members, thread guests' do
              expect(subject).to include *[member, subgroup_member, thread_guest, poll_guest, inviter, invited].map(&:name)
            end

            it 'does not return another organizations members, unrelated users' do
              expect(subject).not_to include *[other_member, unrelated].map(&:name)
            end
          end

          context "group.members_can_add_guests=false" do
            before do
              discussion.group.update(members_can_add_guests: false)
            end

            it 'returns group members, thread guests' do
              expect(subject).to include *[member, thread_guest, poll_guest].map(&:name)
            end

            it 'excludes subgroup members, other org members, unrelated' do
              expect(subject).not_to include *[subgroup_member, other_member, unrelated, inviter, invited].map(&:name)
            end
          end
        end
      end
    end

    context "poll" do
      subject do
        UserQuery.invitable_search(model: poll, actor: actor).pluck(:name)
      end

      context "without group or discussion" do
        context "as admin" do
          before { poll.stances.where(participant_id: actor.id).update_all(admin: true, inviter_id: actor.id) }

          it "returns members of actors groups, actors inviter and invited" do
            expect(subject).to include *[member, subgroup_member, other_member, invited, inviter, poll_guest].map(&:name)
          end

          it 'does not include guests from other models, unrelated' do
            expect(subject).not_to include *[thread_guest, unrelated].map(&:name)
          end
        end

        context "as member" do
          it 'returns poll_guest and actor' do
            expect(subject).to include *[poll_guest, actor].map(&:name)
            expect(subject.size).to eq 2
          end
        end
      end

      context "in discussion, without group" do
        before { poll.update(discussion_id: discussion.id, group_id: nil) }

        context "as discussion admin" do
          before { discussion.discussion_readers.where(user_id: actor.id).update_all(admin: true) }

          it "returns members of actors groups, actors inviter and invited, poll_guest, thread_guest" do
            expect(subject).to include *[member, subgroup_member, other_member, invited, inviter, poll_guest, thread_guest].map(&:name)
          end

          it 'does not include unrelated' do
            expect(subject).not_to include unrelated.name
          end
        end

        context "as discussion member" do
          before { discussion.discussion_readers.where(user_id: actor.id).update_all(admin: false) }

          it 'returns existing members' do
            expect(subject).to include *[poll_guest, thread_guest, actor].map(&:name)
            expect(subject.count).to eq 3
          end
        end
      end

      context "in group" do
        before { poll.update(group: group) }

        context "as group admin" do
          before { Membership.where(user: actor, group: group).update(admin: true) }

          it 'returns group, subgroup members, poll guests, inviters and invited' do
            expect(subject).to include *[member, subgroup_member, poll_guest, inviter, invited].map(&:name)
          end

          it 'does not return another organizations members, unrelated' do
            expect(subject).not_to include *[other_member, thread_guest, unrelated].map(&:name)
          end
        end

        context "as group member" do
          before { Membership.where(user: actor, group: group).update(admin: false) }

          context "and a poll admin" do
            before { Stance.where(participant_id: actor.id, poll_id: poll.id).update_all(admin: true) }

            context "group.members_can_add_guests=true" do
              before { group.update(members_can_add_guests: true) }

              it 'returns group, subgroup members, poll_guests' do
                expect(subject).to include *[member, subgroup_member, poll_guest, invited, inviter].map(&:name)
              end

              it 'does not return another organizations members' do
                expect(subject).to_not include *[other_member, thread_guest, unrelated].map(&:name)
              end
            end

            context "group.members_can_add_guests=false" do
              before { group.update(members_can_add_guests: false) }

              it 'returns group member, poll_guest' do
                expect(subject).to include *[member, poll_guest, actor].map(&:name)
                expect(subject.size).to be 3
              end

              it 'does not return subgroup members, other members, unlreated guests' do
                expect(subject).to_not include *[other_member, thread_guest, unrelated, invited, inviter].map(&:name)
              end
            end
          end

          context "and a poll member" do
            context "group.members_can_add_guests=true" do
              before { poll.group.update(members_can_add_guests: true) }

              context "specified_voters_only=true" do
                before { poll.update(specified_voters_only: true) }

                it 'returns no body' do
                  expect(subject.size).to be 0
                end
              end

              context "specified_voters_only=false" do
                before { poll.update(specified_voters_only: false) }

                it 'returns group, subgroup members, poll_guests' do
                  expect(subject).to include *[member, subgroup_member, poll_guest, invited, inviter].map(&:name)
                end
              end
            end

            context "group.members_can_add_guests=false" do
              before { poll.group.update(members_can_add_guests: false) }

              context "specified_voters_only=true" do
                before { poll.update(specified_voters_only: true) }

                it 'returns nobody' do
                  expect(subject.size).to be 0
                end
              end

              context "specified_voters_only=false" do
                before { poll.update(specified_voters_only: false) }

                it 'returns only people already in the poll, or people in the group' do
                  expect(subject).to include *[poll_guest, actor, member].map(&:name)
                  expect(subject.size).to be 3
                end
              end
            end
          end
        end
      end

    #   context "in group and discussion" do
    #     context "as group admin" do
    #       # context members_can_add_guests is false
    #       it 'returns group members'
    #       it 'returns subgroup members'
    #       it 'returns discussion guests'
    #       it 'does not return unrelated users'
    #     end
    #
    #     context "as group member, but poll admin" do
    #       context "group.members_can_add_guests=true" do
    #         it 'returns group members'
    #         it 'returns subgroup members'
    #         it 'returns discussion guests'
    #         it 'does not return other members'
    #       end
    #
    #       context "group.members_can_add_guests=false" do
    #         it 'returns group members'
    #         it 'returns (existing) discussion guests'
    #         it 'does not return subgroup members'
    #         it 'does not return other members'
    #       end
    #     end
    #   end
    end
  end
end
