require 'rails_helper'
describe API::UsersController do
  let(:user)  { create :user }
  let(:group) { create :formal_group }

  before do
     group.add_member! user
     sign_in user
   end

  describe "mentionable" do
    let!(:jennifer) { create :user, name: 'jennifer', username: 'queenie' }
    let!(:jessica)  { create :user, name: 'jeesica', username: 'queenbee' }
    let!(:emilio)   { create :user, name: 'emilio', username: 'coolguy' }

    before do
      group.add_member! jennifer
    end

    # jennifer and emilio are in the group
    # jessica is not in the group

    it "returns users with name matching fragment" do
      get :index, params: {q: "je"}
      json = JSON.parse(response.body)
      user_ids = json['users'].map { |c| c['id'] }
      expect(user_ids).to     include jennifer.id
      expect(user_ids).to_not include jessica.id
      expect(user_ids).to_not include emilio.id
    end

    it "returns users with username matching fragment" do
      get :index, params: {q: "qu"}
      json = JSON.parse(response.body)
      user_ids = json['users'].map { |c| c['id'] }
      expect(user_ids).to     include jennifer.id
      expect(user_ids).to_not include jessica.id
      expect(user_ids).to_not include emilio.id
    end
  end
end
