require "cancan/matchers"
require 'rails_helper'

describe "poll abilities" do
  let(:actor) { create(:user) }
  let(:group) { create(:group) }
  let(:discussion) { create(:discussion, group: group) }

  let(:ability) { Ability::Base.new(actor) }
  subject { ability }

  context "a poll without group" do
    let(:poll) { create(:poll) }
    context "as poll admin" do
      before { poll.stances.create!(participant_id: actor.id, admin: true, latest: true) }
      it {should be_able_to(:vote_in, poll)}
      it {should be_able_to(:add_members, poll)}
      it {should be_able_to(:announce, poll)}
      it {should be_able_to(:add_guests, poll)}
    end

    context "as poll member" do
      before { poll.stances.create!(participant_id: actor.id, latest: true) }
      it {should     be_able_to(:vote_in, poll)}
      it {should     be_able_to(:add_members, poll)}
      it {should_not be_able_to(:announce, poll)}
      it {should_not be_able_to(:add_guests, poll)}
    end

    context "as unrelated" do
      it {should_not be_able_to(:vote_in, poll)}
      it {should_not be_able_to(:add_members, poll)}
      it {should_not be_able_to(:announce, poll)}
      it {should_not be_able_to(:add_guests, poll)}
    end
  end

  context "a poll in group" do
    let(:poll) { create(:poll, discussion: discussion, group: group) }
    let(:closed_poll) { poll.update(closed_at: Time.now) }

    context "as a group admin" do
      before do
        group.add_admin! actor
        group.update(members_can_announce: false,
                     members_can_add_guests: false)
      end

      it {should be_able_to(:add_members, poll)}
      it {should be_able_to(:announce, poll)}
      it {should be_able_to(:add_guests, poll)}
      it {should be_able_to(:update, poll)}
      it {should_not be_able_to(:update, closed_poll)}

      describe "specified_voters_only=true" do
        before { poll.update(specified_voters_only: true) }
        it {should_not be_able_to(:vote_in, poll)}
      end

      describe "specified_voters_only=false" do
        before { poll.update(specified_voters_only: false) }
        it {should be_able_to(:vote_in, poll)}
      end
    end

    context "as a group member" do
      before { group.add_member! actor }

      context "as a poll admin" do
        before { poll.stances.create!(participant_id: actor.id, admin: true, latest: true) }

        describe "group.members_can_add_guests=true" do
          before { group.update(members_can_add_guests: true) }
          it {should be_able_to(:add_guests, poll)}
        end

        describe "group.members_can_add_guests=false" do
          before { group.update(members_can_add_guests: false) }
          it {should_not be_able_to(:add_guests, poll)}
        end

        describe "group.members_can_announce=true" do
          before { group.update(members_can_announce: true) }
          it {should be_able_to(:announce, poll)}
        end

        describe "group.members_can_announce=false" do
          before { group.update(members_can_announce: false) }
          it {should_not be_able_to(:announce, poll)}
        end
      end

      context "as a poll member" do
        before { poll.stances.create!(participant_id: actor.id, inviter_id: actor.id, latest: true) }

        describe "poll.specified_voters_only=true" do
          before { poll.update(specified_voters_only: true) }

          it {should be_able_to(:vote_in, poll)}

          describe "group.members_can_add_guests=true" do
            before { group.update(members_can_add_guests: true) }
            it {should_not be_able_to(:add_guests, poll)}
          end

          describe "group.members_can_announce=true" do
            before { group.update(members_can_announce: true) }
            it {should_not be_able_to(:announce, poll)}
          end
        end

        describe "poll.specified_voters_only=false" do
          before { poll.update(specified_voters_only: false) }
          it {should be_able_to(:vote_in, poll)}

          describe "group.members_can_add_guests=true" do
            before { group.update(members_can_add_guests: true) }
            it {should be_able_to(:add_guests, poll)}
          end

          describe "group.members_can_announce=true" do
            before { group.update(members_can_announce: true) }
            it {should be_able_to(:announce, poll)}
          end
        end
      end

      context "unrelated to poll" do
        describe "poll.specified_voters_only=true" do
          before { poll.update(specified_voters_only: true) }
          it {should_not be_able_to(:vote_in, poll)}

          describe "group.members_can_add_guests=true" do
            before { group.update(members_can_add_guests: true) }
            it {should_not be_able_to(:add_guests, poll)}
          end

          describe "group.members_can_announce=true" do
            before { group.update(members_can_announce: true) }
            it {should_not be_able_to(:announce, poll)}
          end
        end

        describe "poll.specified_voters_only=false" do
          before { poll.update(specified_voters_only: false) }
          it {should be_able_to(:vote_in, poll)}

          describe "group.members_can_add_guests=true" do
            before { group.update(members_can_add_guests: true) }
            it {should be_able_to(:add_guests, poll)}
          end

          describe "group.members_can_announce=true" do
            before { group.update(members_can_announce: true) }
            it {should be_able_to(:announce, poll)}
          end
        end
      end
    end

    context "unrelated to group" do
      before do
        group.update(members_can_add_guests: true)
        group.update(members_can_announce: true)
        poll.update(specified_voters_only: false)
      end

      it {should_not be_able_to(:vote_in, poll)}
      it {should_not be_able_to(:announce, poll)}
      it {should_not be_able_to(:add_guests, poll)}
      it {should_not be_able_to(:update, poll)}
      it {should_not be_able_to(:destroy, poll)}
      it {should_not be_able_to(:close, poll)}
      it {should_not be_able_to(:reopen, poll)}
      it {should_not be_able_to(:show, poll)}
    end
  end
end
