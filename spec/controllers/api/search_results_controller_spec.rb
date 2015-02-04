require 'rails_helper'
describe API::SearchResultsController do

  let(:user)    { create :user }
  let(:group)   { create :group }
  let(:find_me_discussion) { create :discussion, group: group, title: 'find_me_discussion_title', description: 'find_me_discussion_desc' }
  let(:miss_me_discussion) { create :discussion, group: group, title: 'miss_me_discussion_title', description: 'miss_me_discussion_desc' }
  let(:find_me_motion) { create :motion, discussion: find_me_discussion, name: 'find_me_motion_title', description: 'find_me_motion_desc'}
  let(:miss_me_motion) { create :motion, discussion: find_me_discussion, name: 'miss_me_motion_title', description: 'miss_me_motion_desc'}
  let(:find_me_comment) { create :comment, discussion: find_me_discussion, body: 'find_me_comment_body'}
  let(:miss_me_comment) { create :comment, discussion: find_me_discussion, body: 'miss_me_comment_bidy'}
  let(:secure_discussion) { create :discussion, title: 'miss_me_discussion_secure' }
  let(:secure_motion) { create :motion, name: 'miss_me_motion_secure' }
  let(:secure_comment) { create :comment, body: 'miss_me_comment_secure' }

  describe 'index' do
    before do
      group.admins << user
      sign_in user
    end

    it "filters by discussion" do
      find_me_discussion; miss_me_discussion
      get :index, q: 'find', format: :json
      json = JSON.parse(response.body)
      expect(json.keys).to include *(%w[discussions search_results])
      discussion_ids        = fields_for(json, 'discussions', 'id')

      expect(discussion_ids).to include find_me_discussion.id
      expect(discussion_ids).to_not include miss_me_discussion.id
    end

    it "filters by motion" do
      find_me_motion; miss_me_motion
      get :index, q: 'find', format: :json
      json = JSON.parse(response.body)
      expect(json.keys).to include *(%w[proposals search_results])
      proposal_ids        = fields_for(json, 'proposals', 'id')

      expect(proposal_ids).to include find_me_motion.id
      expect(proposal_ids).to_not include miss_me_motion.id
    end

    it "filters by comment" do
      find_me_comment; miss_me_comment
      get :index, q: 'find', format: :json
      json = JSON.parse(response.body)
      expect(json.keys).to include *(%w[comments search_results])
      comment_ids        = fields_for(json, 'comments', 'id')

      expect(comment_ids).to include find_me_comment.id
      expect(comment_ids).to_not include miss_me_comment.id
    end

    it "does not display content the user does not have access to" do
      secure_discussion; secure_motion; secure_comment
      get :index, q: 'secure', format: :json
      json = JSON.parse(response.body)
      expect(json['search_results']).to eq []
    end
  end
end

def fields_for(json, name, field)
  json[name].map { |f| f[field] }
end