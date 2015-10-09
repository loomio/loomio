require 'rails_helper'
describe API::SearchResultsController do

  let(:user)    { create :user }
  let(:group)   { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:motion) { create :current_motion, discussion: discussion }
  let(:comment) { create :comment, discussion: discussion }

  describe 'index' do
    before do
      group.admins << user
      sign_in user
      @search_setting = ENV['ADVANCED_SEARCH_ENABLED']
      ENV['ADVANCED_SEARCH_ENABLED'] = 'Y'
    end

    after do
      ENV['ADVANCED_SEARCH_ENABLED'] = @search_setting
    end

    it 'does not find irrelevant threads' do
      json = search_for('find')
      discussion_ids = fields_for(json, 'discussion', 'id')
      expect(discussion_ids).to_not include discussion.id
    end

    it "can find a discussion by title" do
      DiscussionService.update discussion: discussion, params: { title: 'find me' }, actor: user
      search_for('find')

      expect(@discussion_ids).to include discussion.id
      expect(@priorities).to include 1
    end

    it "can find a discussion by description" do
      DiscussionService.update discussion: discussion, params: { description: 'find me' }, actor: user
      search_for('find')

      expect(@discussion_ids).to include discussion.id
      expect(@priorities).to include 0.2
    end

    it "can find a discussion by proposal name" do
      motion.update name: 'find me'
      ThreadSearchService.index! motion.discussion_id
      search_for('find')

      expect(@discussion_ids).to include discussion.id
      expect(@motion_ids).to include motion.id
      expect(@priorities).to include 0.4
    end

    it "can find a discussion by proposal description" do
      motion.update description: 'find me'
      ThreadSearchService.index! motion.discussion_id
      search_for('find')

      expect(@discussion_ids).to include discussion.id
      expect(@motion_ids).to include motion.id
      expect(@priorities).to include 0.2
    end

    it "can find a discussion by comment body" do
      comment.update body: 'find me'
      ThreadSearchService.index! comment.discussion_id
      result = search_for('find')
      expect(@discussion_ids).to include discussion.id
      expect(@comment_ids).to include comment.id
      expect(@priorities).to include 0.1
    end

    it "does not display content the user does not have access to" do
      DiscussionService.update discussion: discussion, params: { group: create(:group) }, actor: user
      search_for('find')

      expect(@discussion_ids).to_not include discussion.id
    end
  end
end

def fields_for(json, name, field)
  return [] unless json[name]
  json[name].map { |f| f[field] }
end

def search_for(term)
  get :index, q: term, format: :json
  JSON.parse(response.body).tap do |json|
    expect(json.keys).to include *(%w[search_results])
    @discussion_ids = fields_for(json, 'discussions', 'id')
    @motion_ids     = fields_for(json, 'proposals', 'id')
    @comment_ids    = fields_for(json, 'comments', 'id')
    @priorities     = fields_for(json, 'search_results', 'priority').map(&:to_f)
  end
end
