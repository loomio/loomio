require 'rails_helper'
describe Api::V1::MentionsController do
  let(:user) { create :user, name: 'frank' }
  let(:author) { create :user, name: 'aaidan' }
  let(:other_user) { create :user, name: 'simon' }
  let(:group) { create :group }
  let(:subgroup) { create :group, parent: group }
  let(:other_subgroup) { create :group, parent: group }
  let(:discussion) { build :discussion, group: group, author: author }

  before do
    group.add_member! user
    group.add_member! author
    DiscussionService.create(discussion: discussion, actor: user)
  end

  it "returns redirect when signed out" do
    get :index, params: { discussion_id: discussion.id }
    expect(response.status).to eq 302
  end

  describe "signed in" do
    before do
      sign_in user
    end

    it "returns something" do
      get :index, params: { discussion_id: discussion.id }
      expect(response.status).to eq 200
    end

    it "returns groups" do
      get :index, params: { discussion_id: discussion.id }
      expect(response.status).to eq 200
      rows = JSON.parse(response.body)
      handles = rows.map { |row| row['handle'] }
      expect(handles).to include group.handle
      expect(handles).not_to include subgroup.handle
      expect(handles).not_to include other_subgroup.handle
    end

    it "returns no group if not allowed" do
      discussion.group.update(members_can_announce: false)
      get :index, params: { discussion_id: discussion.id }
      expect(response.status).to eq 200
      rows = JSON.parse(response.body)
      handles = rows.map { |row| row['handle'] }
      expect(handles).not_to include group.handle
      expect(handles).not_to include subgroup.handle
      expect(handles).not_to include other_subgroup.handle
    end

    it "returns users" do
      get :index, params: { discussion_id: discussion.id }
      expect(response.status).to eq 200
      rows = JSON.parse(response.body)
      handles = rows.map { |row| row['handle'] }

      expect(handles).to include user.username
      expect(handles).to include author.username
      expect(handles).not_to include other_user.username
    end

    it "returns filtered results" do
      get :index, params: { discussion_id: discussion.id, q: 'aa' }
      expect(response.status).to eq 200
      rows = JSON.parse(response.body)
      handles = rows.map { |row| row['handle'] }

      expect(handles.length).to eq 1
      expect(handles).to include author.username
      expect(handles).not_to include user.username
      expect(handles).not_to include other_user.username
    end
  end
end
