require 'rails_helper'

describe API::VersionsController do
  let(:user) { create :user }
  let(:discussion) { create :discussion , private: false, title: "Ready Player Zero"}
  let(:comment) { create :comment, discussion:discussion, body: "Ready Player Zero"}

  describe 'show' do
    before do
      discussion.group.add_admin! user
      sign_in user
      discussion.update(title: "Ready Player One")
      discussion.update(private: true)
      discussion.update(title: "Ready Player Two")
      comment.update(body: "Ready Player One")

    end

    it '(zero) should return the original version' do
      get :show, params: { discussion_id: discussion.id, index:0 }
      json = JSON.parse(response.body)
      version_changes = json['versions'][0]['changes']
      expect(version_changes['private']).to eq [nil, false]
      expect(version_changes['title']).to eq [nil, 'Ready Player Zero']
    end

    it '(one) should return name change and not privacy' do
      get :show, params: { discussion_id: discussion.id, index:1 }
      json = JSON.parse(response.body)
      version_changes = json['versions'][0]['changes']
      expect(version_changes['private']).to eq nil
      expect(version_changes['title']).to eq ['Ready Player Zero', 'Ready Player One']
    end

    it '(two) should return privacy and constant name change' do
      get :show, params: { discussion_id: discussion.id, index:2 }
      json = JSON.parse(response.body)
      version_changes = json['versions'][0]['changes']
      expect(version_changes['private']).to eq [false, true]
      expect(version_changes['title']).to eq ['Ready Player One', 'Ready Player One']
    end

    it '(three) final version name change' do
      get :show, params: { discussion_id: discussion.id, index:3 }
      json = JSON.parse(response.body)
      version_changes = json['versions'][0]['changes']
      expect(version_changes['private']).to eq nil
      expect(version_changes['title']).to eq ['Ready Player One', 'Ready Player Two']
    end

    it 'should show original body on zero for comment' do
      get :show, params: { comment_id: comment.id, index:0 }
      json = JSON.parse(response.body)
      version_changes = json['versions'][0]['changes']
      expect(version_changes['body']).to eq ["", 'Ready Player Zero']
    end

    it 'should show first revision on one for comment' do
      get :show, params: { comment_id: comment.id, index:1 }
      json = JSON.parse(response.body)
      version_changes = json['versions'][0]['changes']
      expect(version_changes['body']).to eq ['Ready Player Zero', 'Ready Player One']
    end
  end
end
