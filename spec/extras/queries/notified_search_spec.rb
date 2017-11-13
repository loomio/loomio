require 'rails_helper'

describe Queries::NotifiedSearch do
  let!(:user) { create :user, name: "Patrick Swayze" }
  let!(:another_user) { create :user, name: "Jennifer Grey", username: "pointbreakgal" }
  let!(:stranger) { create :user, name: "Emilio Estevez" }
  let!(:group) { create :formal_group, name: "Dirty Dancing Shoes" }
  let!(:another_group) { create :formal_group, name: "Better Off Dead" }

  before do
    group.add_member! user
    group.add_member! another_user
  end

  def subject(query)
    Queries::NotifiedSearch.new(query, user).results
  end

  describe 'results' do
    it 'finds other users the user shares a group with by name' do
      expect(subject('jennifer').map(&:id)).to include another_user.id
    end

    it 'finds other users the user shares a group with by username' do
      expect(subject('point').map(&:id)).to include another_user.id
    end

    it 'does not find the user' do
      expect(subject('patrick')).to be_empty
    end

    it 'does not find deactivated users' do
      another_user.update(deactivated_at: 1.day.ago)
      expect(subject('jennifer')).to be_empty
    end

    it 'does not find users the user does not know' do
      expect(subject('emilio')).to be_empty
    end

    it 'finds groups the user is a member of' do
      expect(subject('dirty').map(&:id)).to include group.key
    end

    it 'does not find groups the user is not a part of' do
      expect(subject('better')).to be_empty
    end

    it 'does not find empty groups' do
      another_group.memberships.destroy_all
      another_group.add_member! user
      expect(subject('better')).to be_empty
    end

    it 'finds an invitation if the query is an email' do
      expect(subject('wark@wark.com').map(&:title)).to include 'wark@wark.com'
    end

    it 'does not find an invitation if the query is not an email' do
      expect(subject('wark')).to be_empty
    end
  end
end
