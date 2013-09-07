require 'spec_helper'

describe Queries::VisibleMotions do
  let(:user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:motion) { create :motion, discussion: discussion }

  subject do
    Queries::VisibleMotions.new(user: user, groups: [group])
  end

  describe 'viewable_by' do
    context 'everyone (aka public)' do
      before { group.update_attribute(:viewable_by, 'everyone') }

      it 'guests can see motions' do
        subject.should include motion
      end

      it 'members can see motions' do
        group.add_member! user
        subject.should include motion
      end
    end

    context 'members' do
      before { group.update_attribute(:viewable_by, 'members') }

      it 'guests cannot see motions' do
        subject.should_not include motion
      end

      it 'members can see motions' do
        group.add_member! user
        subject.should include motion
      end
    end

    context 'parent_group_members' do
      let(:parent_group) { create :group }
      let(:group) { create :group, parent: parent_group }

      before { group.update_attribute(:viewable_by, 'parent_group_members') }

      it 'guests cannot see motions' do
        subject.should_not include motion
      end

      it 'member of parent group can see motions' do
        parent_group.add_member! user
        subject.should include motion
      end

      it 'members can see motions' do
        parent_group.add_member! user
        group.add_member! user
        subject.should include motion
      end
    end
  end

  describe 'archived' do
    it 'does not return motions in archived groups' do
      motion
      group.archive!
      subject.should_not include motion
    end
  end
end
