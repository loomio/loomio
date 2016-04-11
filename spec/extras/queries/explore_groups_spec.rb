require 'rails_helper'

describe Queries::ExploreGroups do
  let(:group)              { create :group }
  let!(:discussion)        { create :discussion, group: group  }
  let!(:second_discussion) { create :discussion, group: group  }
  let!(:third_discussion)  { create :discussion, group: group  }
  let!(:fourth_discussion) { create :discussion, group: group  }

  before do
    group.update_attribute(:is_visible_to_public, true)
    group.update_attribute(:created_at, 3.months.ago)
    group.update_attribute(:memberships_count, 4)
    discussion.update_attribute(:last_comment_at, 1.day.ago)
  end

  describe 'visible groups' do

    it 'shows groups on the explore page' do
      expect(Queries::ExploreGroups.new).to include group
    end

    it 'only shows groups that are visible to public' do
      group.update_attribute(:is_visible_to_public, false)
      expect(Queries::ExploreGroups.new).to_not include group
    end

    it 'only shows parent groups' do
      subgroup = FactoryGirl.create(:group, parent: group)
      subgroup.update_attribute(:is_visible_to_public, true)
      subgroup.update_attribute(:created_at, 3.months.ago)
      subgroup.update_attribute(:memberships_count, 3)
      4.times do
        discussion = FactoryGirl.create(:discussion, group: subgroup)
        discussion.update_attribute(:last_comment_at, 1.day.ago)
      end
      expect(Queries::ExploreGroups.new).to_not include subgroup
    end

    it 'only shows groups that are more than 2 months old' do
      group.update_attribute(:created_at, 1.month.ago)
      expect(Queries::ExploreGroups.new).to_not include group
    end

    it 'only shows groups with recent activity' do
      discussion.update_attribute(:last_comment_at, 2.months.ago)
      expect(Queries::ExploreGroups.new).to_not include group
    end

    it 'only shows groups with more than three members' do
      group.update_attribute(:memberships_count, 3)
      expect(Queries::ExploreGroups.new).to_not include group
    end

    it 'only shows groups that have more than three discussions' do
      group.update_attribute(:discussions_count, 3)
      expect(Queries::ExploreGroups.new).to_not include group
    end
  end

  describe '#search_for' do

    it 'returns groups with names that match the query' do
      group.update_attribute(:name, 'Explore group')
      query = Queries::ExploreGroups.new
      expect(query.search_for('explore')).to include group
    end

    it 'returns groups with descriptions that match the query' do
      group.update_attribute(:description, 'A group for exploring')
      query = Queries::ExploreGroups.new
      expect(query.search_for('exploring')).to include group
    end

    it 'does not return groups with names or descriptions that do not match the query' do
      group.update_attribute(:name, 'Group')
      query = Queries::ExploreGroups.new
      expect(query.search_for('explore')).to_not include group
    end

    it 'returns all visible groups when query is not present' do
      query = Queries::ExploreGroups.new
      expect(query.search_for(nil)).to include group
    end
  end
end
