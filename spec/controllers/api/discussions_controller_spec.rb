require 'rails_helper'
describe API::DiscussionsController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :group }
  let(:subgroup) { create :group, parent: group }
  let(:another_group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:participating_discussion) { create :discussion, group: group }
  let(:subgroup_discussion) { create :discussion, group: subgroup }
  let(:muted_discussion) { create :discussion, group: group }
  let(:old_discussion) { create :discussion, group: group, created_at: 4.months.ago, last_activity_at: 4.months.ago }
  let(:motionless_discussion) { create :discussion, group: group }
  let(:comment) { create :comment, discussion: discussion}
  let(:proposal) { create :motion, discussion: discussion, author: user }
  let(:discussion_params) {{
    title: 'Did Charlie Bite You?',
    description: 'From the dawn of internet time...',
    group_id: group.id,
    private: true
  }}

  before do
    group.add_admin! user
    another_group.add_member! user
    subgroup.add_member! user
    sign_in user
    discussion.reload
    DiscussionReader.for(user: user, discussion: muted_discussion).set_volume! 'mute'
  end

  describe 'dashboard_discussions' do
    it 'returns discussions with activity after a certain date' do
      old_discussion.reload
      get :discussions_for_dashboard
      json = JSON.parse(response.body)
      ids = json['discussions'].map { |v| v['id'] }
      expect(ids).to include discussion.id
      expect(ids).to_not include old_discussion.id
    end

    it 'does not return muted discussions by default' do
      muted_discussion.reload
      get :discussions_for_dashboard
      json = JSON.parse(response.body)
      ids = json['discussions'].map { |v| v['id'] }
      expect(ids).to_not include muted_discussion.id
    end

    it 'can filter by active proposals' do
      proposal.reload
      motionless_discussion.reload
      get :discussions_for_dashboard, filter: :show_proposals
      json = JSON.parse(response.body)
      ids = json['discussions'].map { |v| v['id'] }
      expect(ids).to include discussion.id
      expect(ids).to_not include motionless_discussion.id
    end

    it 'can filter by participating' do
      CommentService.create actor: user, comment: build(:comment, discussion: participating_discussion)
      get :discussions_for_dashboard, filter: :show_participating
      json = JSON.parse(response.body)
      ids = json['discussions'].map { |v| v['id'] }
      expect(ids).to include participating_discussion.id
      expect(ids).to_not include discussion.id  
    end

    it 'can filter by muted' do
      muted_discussion.reload
      get :discussions_for_dashboard, filter: :show_muted
      json = JSON.parse(response.body)
      ids = json['discussions'].map { |v| v['id'] }
      expect(ids).to include muted_discussion.id
      expect(ids).to_not include discussion.id
    end
  end

  describe 'inbox_discussions' do
  end

  describe 'show' do
    it 'returns the discussion json' do
      proposal
      get :show, id: discussion.key
      json = JSON.parse(response.body)
      expect(json.keys).to include *(%w[users groups proposals discussions])
      expect(json['discussions'][0].keys).to include *(%w[id key title description last_item_at last_comment_at created_at updated_at items_count comments_count private author_id group_id active_proposal_id])
    end
  end

  describe 'index' do
    let(:another_discussion)    { create :discussion }

    before do
      discussion; another_discussion
    end

    context 'success' do
      it 'returns discussions filtered by group' do
        get :index, group_id: group.id, format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[discussions])
        discussions = json['discussions'].map { |v| v['id'] }
        expect(discussions).to include discussion.id
        expect(discussions).to_not include another_discussion.id
      end

      it 'does not display discussions not visible to the current user' do
        cant_see_me = create :discussion
        get :index, group_id: group.id, format: :json
        json = JSON.parse(response.body)
        discussions = json['discussions'].map { |v| v['id'] }
        expect(discussions).to_not include cant_see_me.id
      end

      it 'responds to a since parameter' do
        four_months_ago = create :discussion, group: group, created_at: 4.months.ago, last_activity_at: 4.months.ago
        two_months_ago = create :discussion, group: group, created_at: 2.months.ago, last_activity_at: 2.months.ago
        get :index, group_id: group.id, format: :json, since: 3.months.ago
        json = JSON.parse(response.body)
        discussions = json['discussions'].map { |v| v['id'] }
        expect(discussions).to include two_months_ago.id
        expect(discussions).to_not include four_months_ago.id
      end

      it 'responds to an until parameter' do
        four_months_ago = create :discussion, group: group, created_at: 4.months.ago, last_activity_at: 4.months.ago
        two_months_ago = create :discussion, group: group, created_at: 2.months.ago, last_activity_at: 2.months.ago
        get :index, group_id: group.id, format: :json, until: 3.months.ago
        json = JSON.parse(response.body)
        discussions = json['discussions'].map { |v| v['id'] }
        expect(discussions).to include four_months_ago.id
        expect(discussions).to_not include two_months_ago.id
      end
    end
  end

  describe 'update' do
    context 'success' do
      it "updates a discussion" do
        post :update, id: discussion.id, discussion: discussion_params, format: :json
        expect(response).to be_success
        expect(discussion.reload.title).to eq discussion_params[:title]
      end
    end

    context 'failures' do
      it "responds with an error when there are unpermitted params" do
        discussion_params[:dontmindme] = 'wild wooly byte virus'
        put :update, id: discussion.id, discussion: discussion_params
        expect(JSON.parse(response.body)['exception']).to eq 'ActionController::UnpermittedParameters'
      end

      it "responds with an error when the user is unauthorized" do
        sign_in another_user
        put :update, id: discussion.id, discussion: discussion_params
        expect(JSON.parse(response.body)['exception']).to eq 'CanCan::AccessDenied'
      end

      it "responds with validation errors when they exist" do
        discussion_params[:title] = ''
        put :update, id: discussion.id, discussion: discussion_params, format: :json
        json = JSON.parse(response.body)
        expect(response.status).to eq 422
        expect(json['errors']['title']).to include 'can\'t be blank'
      end
    end
  end

  describe 'create' do
    context 'success' do
      it "creates a discussion" do
        post :create, discussion: discussion_params, format: :json
        expect(response).to be_success
        expect(Discussion.last).to be_present
      end

      it 'responds with json' do
        post :create, discussion: discussion_params, format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[users groups proposals discussions])
        expect(json['discussions'][0].keys).to include *(%w[
          id
          key
          title
          description
          last_item_at
          last_comment_at
          created_at
          updated_at
          items_count
          comments_count
          private
          active_proposal_id
          author_id
          group_id
        ])
      end
    end

    context 'failures' do
      it "responds with an error when there are unpermitted params" do
        discussion_params[:dontmindme] = 'wild wooly byte virus'
        post :create, discussion: discussion_params
        expect(JSON.parse(response.body)['exception']).to eq 'ActionController::UnpermittedParameters'
      end

      it "responds with an error when the user is unauthorized" do
        sign_in another_user
        post :create, discussion: discussion_params
        expect(JSON.parse(response.body)['exception']).to eq 'CanCan::AccessDenied'
      end

      it "responds with validation errors when they exist" do
        discussion_params[:title] = ''
        post :create, discussion: discussion_params, format: :json
        json = JSON.parse(response.body)
        expect(response.status).to eq 422
        expect(json['errors']['title']).to include 'can\'t be blank'
      end
    end
  end

end
