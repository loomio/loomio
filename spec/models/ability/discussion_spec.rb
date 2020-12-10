require "cancan/matchers"
require 'rails_helper'

describe "discussion abilities" do
  let(:actor) { create(:user) }
  let(:group) { create(:group) }

  let(:ability) { Ability::Base.new(actor) }
  subject { ability }

  context "a discussion without group" do
    let(:discussion) { create(:discussion, group: nil) }

    context "as discussion admin" do
      before { discussion.discussion_readers.create!(user_id: actor.id, admin: true, inviter_id: actor.id) }
      it {should be_able_to(:announce, discussion)}
      it {should be_able_to(:add_guests, discussion)}
      it {should be_able_to(:update, discussion)}
    end

    context "as discussion member" do
      before { discussion.discussion_readers.create!(user_id: actor.id, admin: false, inviter_id: actor.id) }
      it {should_not be_able_to(:announce, discussion)}
      it {should_not be_able_to(:add_guests, discussion)}
      it {should     be_able_to(:update, discussion)}
    end

    context "as unrelated" do
      it {should_not be_able_to(:announce, discussion)}
      it {should_not be_able_to(:add_guests, discussion)}
      it {should_not be_able_to(:update, discussion)}
    end
  end

  context "a discussion in group" do
    let(:discussion) { create(:discussion, group: group) }

    context "as a group admin" do
      before { group.add_admin! actor }

      it {should be_able_to(:add_members, discussion)}
      it {should be_able_to(:announce, discussion)}
      it {should be_able_to(:add_guests, discussion)}
    end

    context "as a group member" do
      before { group.add_member! actor }

      context "as a discussion admin" do
        before { discussion.discussion_readers.create!(user_id: actor.id, admin: true) }

        describe "group.members_can_add_guests=true" do
          before { group.update(members_can_add_guests: true) }
          it {should be_able_to(:add_guests, discussion)}
        end

        describe "group.members_can_add_guests=false" do
          before { group.update(members_can_add_guests: false) }
          it {should_not be_able_to(:add_guests, discussion)}
        end

        describe "group.members_can_announce=true" do
          before { group.update(members_can_announce: true) }
          it {should be_able_to(:announce, discussion)}
        end

        describe "group.members_can_announce=false" do
          before { group.update(members_can_announce: false) }
          it {should_not be_able_to(:announce, discussion)}
        end
      end

      describe "group.members_can_add_guests=true" do
        before { group.update(members_can_add_guests: true) }
        it {should be_able_to(:add_guests, discussion)}
      end

      describe "group.members_can_announce=true" do
        before { group.update(members_can_announce: true) }
        it {should be_able_to(:announce, discussion)}
      end

      describe "members_can_edit_discussions=true" do
        before { group.update(members_can_edit_discussions: true) }
        it { should be_able_to(:update, discussion) }
      end

      context "members_can_edit_discussions=false" do
        before { group.update(members_can_edit_discussions: false) }
        it { should_not be_able_to(:update, discussion) }
      end
    end
  end
end
