require 'rails_helper'
describe API::SearchController do

  let(:user)    { create :user }
  let(:group)   { create :formal_group }
  let(:discussion) { create :discussion, group: group }
  let(:comment) { create :comment, discussion: discussion }

  describe 'index' do
    before do
      group.add_admin! user
      sign_in user
    end

    it 'does not find irrelevant threads' do
      json = search_for('find')
      result_keys = fields_for(json, 'search_results', 'key')
      expect(result_keys).to_not include discussion.key
    end

    it "can find a discussion by title" do
      DiscussionService.update discussion: discussion, params: { title: 'find me' }, actor: user
      search_for('find')

      expect(@result_keys).to include discussion.key
      expect(@ranks).to include SearchVector::WEIGHT_VALUES[3] * SearchVector::RECENCY_VALUES[0]
    end

    # TODO: Pull this stuff out so it's not so magic number-y
    it "decays relevance for older posts" do
      DiscussionService.update discussion: discussion, params: { title: 'find me' }, actor: user
      discussion.update(last_activity_at: 10.days.ago)
      result = search_for('find')
      expect(@ranks).to include SearchVector::WEIGHT_VALUES[3] * 0.8

      discussion.update(last_activity_at: 30.days.ago)
      result = search_for('find')
      expect(@ranks).to include SearchVector::WEIGHT_VALUES[3] * 0.5

      discussion.update(last_activity_at: 60.days.ago)
      result = search_for('find')
      expect(@ranks).to include SearchVector::WEIGHT_VALUES[3] * 0.1
    end

    it "can find a discussion by description" do
      DiscussionService.update discussion: discussion, params: { description: 'find me' }, actor: user
      search_for('find')

      expect(@result_keys).to include discussion.key
      expect(@ranks).to include SearchVector::WEIGHT_VALUES[1] * SearchVector::RECENCY_VALUES[0]
    end

    it "can find a discussion by comment body" do
      comment.update body: 'find me'
      SearchVector.index! comment.discussion_id
      result = search_for('find')
      expect(@result_keys).to include discussion.key
      expect(@ranks).to include SearchVector::WEIGHT_VALUES[0] * SearchVector::RECENCY_VALUES[0]
    end

    it "does not display content the user does not have access to" do
      DiscussionService.update discussion: discussion, params: { group: create(:formal_group) }, actor: user
      search_for('find')

      expect(@result_keys).to_not include discussion.key
    end
  end
end

def fields_for(json, name, field)
  return [] unless json[name]
  json[name].map { |f| f[field] }
end

def search_for(term)
  get :index, params: { q: term }, format: :json
  JSON.parse(response.body).tap do |json|
    expect(json.keys).to include *(%w[search_results])
    @result_keys = fields_for(json, 'search_results', 'key')
    @ranks      = fields_for(json, 'search_results', 'rank').map { |d| d.to_f.round(2) }
  end
end
