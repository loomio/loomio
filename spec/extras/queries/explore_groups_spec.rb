require 'rails_helper'

describe Queries::ExploreGroups do
  let(:group)              { create :formal_group }
  let(:second_group)       { create :formal_group }
  let(:archived_group)     { create :formal_group, archived_at: 1.day.ago }

  before do
    group.update_attribute(:is_visible_to_public, true)
    second_group.update_attribute(:is_visible_to_public, true)
    archived_group.update_attribute(:is_visible_to_public, true)
    group.update_attribute(:memberships_count, 5)
    group.update_attribute(:discussions_count, 3)
    group.subscription = Subscription.create(plan: 'trial', state: 'active')
    group.save
    second_group.update_attribute(:memberships_count, 4)
    second_group.update_attribute(:discussions_count, 1)
    second_group.subscription = Subscription.create(plan: 'trial', state: 'active')
    second_group.save
    archived_group.update_attribute(:memberships_count, 5)
    archived_group.update_attribute(:discussions_count, 3)
    archived_group.subscription = Subscription.create(plan: 'trial', state: 'active')
    archived_group.save
  end

  describe 'visible groups' do

    it 'shows groups on the explore page' do
      expect(Queries::ExploreGroups.new).to include group
      expect(Queries::ExploreGroups.new).to_not include archived_group
    end

    it 'only shows groups that are visible to public' do
      group.update_attribute(:is_visible_to_public, false)
      expect(Queries::ExploreGroups.new).to_not include group
    end

    it 'only shows parent groups' do
      subgroup = FactoryBot.create(:formal_group, parent: group)
      subgroup.update_attribute(:is_visible_to_public, true)
      expect(Queries::ExploreGroups.new).to_not include subgroup
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
