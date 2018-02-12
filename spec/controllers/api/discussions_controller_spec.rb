require 'rails_helper'
describe API::DiscussionsController do

  let(:subgroup) { create :formal_group, parent: group }
  let(:another_group) { create :formal_group }
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :formal_group }
  let(:discussion) { create :discussion, group: group }
  let(:poll) { create :poll, discussion: discussion }
  let(:reader) { DiscussionReader.for(user: user, discussion: discussion) }
  let(:another_discussion) { create :discussion }
  let(:comment) { create :comment, discussion: discussion}
  let(:new_comment) { build(:comment, discussion: discussion) }
  let(:discussion_params) {{
    title: 'Did Charlie Bite You?',
    description: 'From the dawn of internet time...',
    group_id: group.id,
    private: true
  }}

  before do
    group.add_admin! user
  end

  context 'as an oauthed user' do
    let(:user) { create(:user) }
    let(:access_token) { create :access_token, resource_owner_id: user.id }

    it 'can fetch records' do
      discussion; another_discussion
      get :dashboard, params: { access_token: access_token.token }
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      discussion_ids = json['discussions'].map { |d| d['id'] }
      expect(discussion_ids).to include discussion.id
      expect(discussion_ids).to_not include another_discussion.id
    end

    it 'returns forbidden if the access token is not found' do
      get :dashboard, params: { access_token: "blargety blarg" }
      expect(response.status).to eq 403
    end

    it 'returns unauthorized if the access token has been revoked' do
      access_token.update(revoked_at: 2.days.ago)
      get :dashboard, params: { access_token: access_token.token }
      expect(response.status).to eq 401
    end

    it 'returns unauthorized if the access token is expired' do
      access_token.update(expires_in: 0)
      get :dashboard, params: { access_token: access_token.token }
      expect(response.status).to eq 401
    end
  end

  describe 'inbox' do
    context 'logged out' do
      it 'responds with forbidden for logged out users' do
        get :inbox
        expect(response.status).to eq 403
      end
    end

    context 'logged in' do
      before do
        sign_in user
        reader.viewed!
        group.add_member! another_user
      end

      it 'returns unread threads' do
        CommentService.create(comment: new_comment, actor: another_user)
        reader
        get :inbox
        json = JSON.parse(response.body)
        discussion_ids = json['discussions'].map { |d| d['id'] }
        reader_ids     = json['discussions'].map { |d| d['discussion_reader_id'] }
        expect(discussion_ids).to include discussion.id
        expect(reader_ids).to include reader.id
      end

      it 'does not return read threads' do
        get :inbox
        json = JSON.parse(response.body)
        expect(json['discussions']).to be_blank
      end

      it 'does not return dismissed threads' do
        CommentService.create(comment: new_comment, actor: another_user)
        DiscussionReader.for(discussion: discussion, user: user).dismiss!
        get :inbox
        json = JSON.parse(response.body)
        expect(json['discussions']).to be_blank
      end

      it 'does not return threads in muted discussions' do
        CommentService.create(comment: new_comment, actor: another_user)
        DiscussionService.update_reader(discussion: discussion, params: { volume: :mute}, actor: user)
        get :inbox
        json = JSON.parse(response.body)
        expect(json['discussions']).to be_blank
      end

      it 'does not return threads in muted groups' do
        CommentService.create(comment: new_comment, actor: another_user)
        Membership.find_by(user: user, group: group).set_volume! :mute
        get :inbox
        json = JSON.parse(response.body)
        expect(json['discussions']).to be_blank
      end

      it 'includes active polls' do
        poll
        CommentService.create(comment: new_comment, actor: another_user)
        get :inbox
        json = JSON.parse(response.body)
        poll_ids = json['polls'].map { |p| p['id'] }
        expect(poll_ids).to include poll.id
      end
    end
  end

  describe 'dashboard' do
    context 'logged out' do
      it 'responds with forbidden for logged out users' do
        get :dashboard
        expect(response.status).to eq 403
      end
    end

    describe 'filtering' do
      let(:subgroup_discussion) { create :discussion, group: subgroup }
      let(:muted_discussion) { create :discussion, group: group }
      let(:old_discussion) { create :discussion, group: group, created_at: 4.months.ago, last_activity_at: 4.months.ago }
      let(:motionless_discussion) { create :discussion, group: group }

      before do
        sign_in user
        another_group.add_member! user
        subgroup.add_member! user
        discussion.reload
        DiscussionReader.for(user: user, discussion: muted_discussion).set_volume! 'mute'
      end

      it 'does not return muted discussions by default' do
        muted_discussion.reload
        get :dashboard
        json = JSON.parse(response.body)
        ids = json['discussions'].map { |v| v['id'] }
        expect(ids).to_not include muted_discussion.id
      end

      it 'can filter by muted' do
        muted_discussion.reload
        get :dashboard, params: { filter: :show_muted }
        json = JSON.parse(response.body)
        ids = json['discussions'].map { |v| v['id'] }
        expect(ids).to include muted_discussion.id
        expect(ids).to_not include discussion.id
      end

      it 'can filter since a certain date' do
        old_discussion.reload
        get :dashboard, params: { since: 3.months.ago }
        json = JSON.parse(response.body)
        ids = json['discussions'].map { |v| v['id'] }
        expect(ids).to include discussion.id
        expect(ids).to_not include old_discussion.id
      end

      it 'can filter until a certain date' do
        old_discussion.reload
        get :dashboard, params: { until: 3.months.ago }
        json = JSON.parse(response.body)
        ids = json['discussions'].map { |v| v['id'] }
        expect(ids).to_not include discussion.id
        expect(ids).to include old_discussion.id
      end

      it 'can limit collection size' do
        discussion; old_discussion; muted_discussion
        get :dashboard, params: { limit: 2 }
        json = JSON.parse(response.body)
        expect(json['discussions'].count).to eq 2
      end
    end
  end

  describe 'show' do
    context 'logged in' do
      before { sign_in user }
      it 'returns the discussion json' do
        get :show, params: { id: discussion.key }
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[users groups discussions])
        expect(json['discussions'][0].keys).to include *(%w[id key title description last_activity_at created_at updated_at items_count private author_id group_id ])
      end

      it 'returns the reader fields' do
        DiscussionReader.for(user: user, discussion: discussion).update(volume: :mute)
        get :show, params: { id: discussion.key }
        json = JSON.parse(response.body)
        expect(json['discussions'][0]['discussion_reader_volume']).to eq "mute"
      end
    end

    context 'logged out' do
      let(:public_discussion) { create :discussion, private: false }
      let(:private_discussion) { create :discussion, private: true }

      it 'returns a public discussions' do
        get :show, params: { id: public_discussion.id }, format: :json
        json = JSON.parse(response.body)
        discussion_ids = json['discussions'].map { |d| d['id'] }
        expect(discussion_ids).to_not include private_discussion.id
        expect(discussion_ids).to include public_discussion.id
      end

      it 'returns unauthorized for a private discussion' do
        get :show, params: { id: private_discussion.id }, format: :json
        expect(response.status).to eq 403
      end
    end
  end

  describe 'dismiss' do
    before { sign_in user }

    let(:reader) { DiscussionReader.for(user: user, discussion: discussion) }

    before do
      group.add_admin! user
      sign_in user
      reader.update(volume: DiscussionReader.volumes[:normal])
      reader.reload
    end

    it "updates dismissed_at" do
      patch :dismiss, params: { id: discussion.key }
      expect(response.status).to eq 200
      expect(reader.reload.dismissed_at).to be_present
    end
  end

  describe 'recall' do
    before { sign_in user }

    let(:reader) { DiscussionReader.for(user: user, discussion: discussion) }

    before do
      group.add_admin! user
      sign_in user
      reader.update(volume: DiscussionReader.volumes[:normal], dismissed_at: 1.day.ago)
      reader.reload
    end

    it "updates dismissed_at to be nil" do
      patch :recall, params: { id: discussion.key }
      expect(response.status).to eq 200
      expect(reader.reload.dismissed_at).to be_nil
    end
  end

  describe 'move' do
    before { sign_in user }

    context 'success' do
      it 'moves a discussion' do
        destination_group = create :formal_group
        destination_group.members << user
        source_group = discussion.group
        patch :move, params: { id: discussion.id, group_id: destination_group.id }, format: :json

        # Discussion belongs to new group
        # The eventable of the event is the old group
        expect(discussion.reload.group).to eq destination_group
      end
    end
  end

  describe 'index' do
    let(:another_discussion)    { create :discussion, group: another_group }

    before do
      discussion; another_discussion
    end

    context 'logged out' do
      let!(:public_discussion) { create :discussion, private: false }
      let!(:private_discussion) { create :discussion, private: true }

      it 'returns a list of public discussions' do
        get :index, format: :json
        json = JSON.parse(response.body)
        discussion_ids = json['discussions'].map { |d| d['id'] }
        expect(discussion_ids).to_not include private_discussion.id
        expect(discussion_ids).to include public_discussion.id
      end
    end

    context 'logged in' do
      before { sign_in user }

      context 'success' do
        it 'returns discussions filtered by group' do
          get :index, params: { group_id: group.id }, format: :json
          json = JSON.parse(response.body)
          expect(json.keys).to include *(%w[discussions])
          discussions = json['discussions'].map { |v| v['id'] }
          expect(discussions).to include discussion.id
          expect(discussions).to_not include another_discussion.id
        end

        it 'does not display discussions not visible to the current user' do
          cant_see_me = create :discussion
          get :index, params: { group_id: group.id }, format: :json
          json = JSON.parse(response.body)
          discussions = json['discussions'].map { |v| v['id'] }
          expect(discussions).to_not include cant_see_me.id
        end

        it 'can display content from a specified public group' do
          public_group = create :formal_group, discussion_privacy_options: :public_only, is_visible_to_public: true
          can_see_me = create :discussion, group: public_group, private: false
          get :index, params: { group_id: public_group.id }, format: :json
          json = JSON.parse(response.body)
          discussions = json['discussions'].map { |v| v['id'] }
          expect(discussions).to include can_see_me.id
        end

        it 'responds to a since parameter' do
          four_months_ago = create :discussion, group: group, created_at: 4.months.ago, last_activity_at: 4.months.ago
          two_months_ago = create :discussion, group: group, created_at: 2.months.ago, last_activity_at: 2.months.ago
          get :index, params: { group_id: group.id, since: 3.months.ago }, format: :json
          json = JSON.parse(response.body)
          discussions = json['discussions'].map { |v| v['id'] }
          expect(discussions).to include two_months_ago.id
          expect(discussions).to_not include four_months_ago.id
        end

        it 'responds to an until parameter' do
          four_months_ago = create :discussion, group: group, created_at: 4.months.ago, last_activity_at: 4.months.ago
          two_months_ago = create :discussion, group: group, created_at: 2.months.ago, last_activity_at: 2.months.ago
          get :index, params: { group_id: group.id, until: 3.months.ago }, format: :json
          json = JSON.parse(response.body)
          discussions = json['discussions'].map { |v| v['id'] }
          expect(discussions).to include four_months_ago.id
          expect(discussions).to_not include two_months_ago.id
        end

        it 'responds with active polls' do
          poll
          get :index, params: { group_id: group.id }, format: :json
          json = JSON.parse(response.body)
          poll_ids = json['polls'].map { |p| p['id'] }
          expect(poll_ids).to include poll.id
        end
      end
    end
  end

  describe 'set_volume' do
    before { sign_in user }

    context 'success' do
      it 'sets the volume of a thread' do
        reader = DiscussionReader.for(user: user, discussion: discussion)
        reader.update volume: :loud
        put :set_volume, params: { id: discussion.id, volume: :mute }, format: :json
        expect(response).to be_success
        expect(reader.reload.volume.to_sym).to eq :mute
      end
    end

    context 'failure' do
      it 'does not update a reader' do
        reader = DiscussionReader.for(user: user, discussion: another_discussion)
        reader.update volume: :loud
        put :set_volume, params: { id: another_discussion.id, volume: :mute }, format: :json
        expect(response).not_to be_success
        expect(reader.reload.volume.to_sym).not_to eq :mute
      end
    end
  end

  describe 'update' do
    before { sign_in user }
    let(:document) { create(:document) }

    context 'success' do
      it "updates a discussion" do
        post :update, params: { id: discussion.id, discussion: discussion_params }, format: :json
        expect(response).to be_success
        expect(discussion.reload.title).to eq discussion_params[:title]
      end

      it 'adds documents' do
        discussion_params[:document_ids] = [document.id]
        post :update, params: { id: discussion.id, discussion: discussion_params }
        expect(discussion.reload.documents).to include document
        expect(response.status).to eq 200
        expect(discussion.reload.document_ids).to include document.id
      end

      it 'removes documents' do
        document.update(model: discussion)
        discussion_params[:document_ids] = []
        expect { post :update, params: { id: discussion.id, discussion: discussion_params } }.to change { Document.count }.by(-1)
        expect(discussion.reload.documents).to be_empty
        expect(response.status).to eq 200
        expect(discussion.reload.document_ids).to_not include document.id
      end
    end

    context 'failures' do
      it "responds with an error when there are unpermitted params" do
        discussion_params[:dontmindme] = 'wild wooly byte virus'
        put :update, params: { id: discussion.id, discussion: discussion_params }
        expect(JSON.parse(response.body)['exception']).to eq 'ActionController::UnpermittedParameters'
      end

      it "responds with an error when the user is unauthorized" do
        sign_in another_user
        put :update, params: { id: discussion.id, discussion: discussion_params }
        expect(JSON.parse(response.body)['exception']).to eq 'CanCan::AccessDenied'
      end

      it "responds with validation errors when they exist" do
        discussion_params[:title] = ''
        put :update, params: { id: discussion.id, discussion: discussion_params }, format: :json
        json = JSON.parse(response.body)
        expect(response.status).to eq 422
        expect(json['errors']['title']).to include 'can\'t be blank'
      end
    end
  end

  describe 'create' do
    before { sign_in user }

    context 'success' do
      it "creates a discussion" do
        post :create, params: { discussion: discussion_params }, format: :json
        expect(response).to be_success
        expect(Discussion.last).to be_present
      end

      describe 'make_announcement' do
        it 'does not email users for non-announcements' do
          expect { post :create, params: { discussion: discussion_params }, format: :json }.to_not change { ActionMailer::Base.deliveries.count }
        end

        it 'makes an announcement' do
          discussion_params[:make_announcement] = true
          expect { post :create, params: { discussion: discussion_params }, format: :json }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end
      end

      it 'responds with json' do
        post :create, params: { discussion: discussion_params }, format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[users groups discussions])
        expect(json['discussions'][0].keys).to include *(%w[
          id
          key
          title
          description
          last_activity_at
          created_at
          updated_at
          items_count
          private
          author_id
          group_id
        ])
      end

      describe 'mentioning' do
        it 'mentions appropriate users' do
          group.add_member! another_user
          discussion_params[:description] = "Hello, @#{another_user.username}!"
          expect { post :create, params: { discussion: discussion_params }, format: :json }.to change { Event.where(kind: :user_mentioned).count }.by(1)
        end

        it 'does not mention users not in the group' do
          discussion_params[:description] = "Hello, @#{another_user.username}!"
          expect { post :create, params: { discussion: discussion_params }, format: :json }.to_not change { Event.where(kind: :user_mentioned).count }
        end
      end
    end

    context 'failures' do
      it "responds with an error when there are unpermitted params" do
        discussion_params[:dontmindme] = 'wild wooly byte virus'
        post :create, params: { discussion: discussion_params }
        expect(JSON.parse(response.body)['exception']).to eq 'ActionController::UnpermittedParameters'
      end

      it "responds with an error when the user is unauthorized" do
        sign_in another_user
        post :create, params: { discussion: discussion_params }
        expect(JSON.parse(response.body)['exception']).to eq 'CanCan::AccessDenied'
      end

      it "responds with validation errors when they exist" do
        discussion_params[:title] = ''
        post :create, params: { discussion: discussion_params }, format: :json
        json = JSON.parse(response.body)
        expect(response.status).to eq 422
        expect(json['errors']['title']).to include 'can\'t be blank'
      end
    end
  end

  describe 'mark_as_seen' do
    it 'marks a discussion as seen' do
      sign_in user
      expect { post :mark_as_seen, params: { id: discussion.id } }.to change { user.discussion_readers.count }.by(1)
      dr = DiscussionReader.last
      expect(dr.discussion).to eq discussion
      expect(dr.last_read_at).to be_present
      expect(dr.read_items_count).to eq 0
    end

    it 'does not allow non-users to mark discussions as seen' do
      post :mark_as_seen, params: { id: discussion.id }
      expect(response.status).to eq 403
    end
  end

  describe 'mark_as_read' do
    let!(:event) { create :event, sequence_id: 2, discussion: discussion, user: another_user }
    let!(:another_event) { create :event, sequence_id: 3 }

    context 'signed out' do
      it 'does not attempt to mark discussions as read while logged out' do
        patch :mark_as_read, params: { id: discussion.id, ranges: "2-2" }
        expect(response.status).to eq 403
      end
    end

    context 'signed in' do
      before do
        sign_in user
        group.add_admin! user
        reader.update(volume: DiscussionReader.volumes[:normal])
        reader.reload
      end

      it "Marks thread item as read" do
        patch :mark_as_read, params: { id: discussion.id, ranges: "2-2" }
        expect(reader.reload.last_read_at).to be_within(2.seconds).of Time.now
        expect(reader.read_items_count).to eq 1
        expect(reader.has_read?(2)).to be true
        expect(response.status).to eq 200
      end
      #
      # it 'does not mark an inaccessible discussion as read' do
      #   patch :mark_as_read, id: another_event.sequence_id
      #   expect(response.status).to eq 403
      #   expect(reader.reload.read_items_count).to eq 0
      # end

      it 'responds with reader fields' do
        # also testing accumulation
        new_comment.discussion = discussion
        CommentService.create(comment: new_comment, actor: user)
        patch :mark_as_read, params: { id: discussion.id, ranges: "2-2" }
        patch :mark_as_read, params: { id: discussion.id, ranges: "3-3" }
        json = JSON.parse(response.body)
        reader.reload

        expect(json['discussions'][0]['id']).to eq discussion.id
        expect(json['discussions'][0]['discussion_reader_id']).to eq reader.id
        expect(json['discussions'][0]['read_ranges']).to eq [[2,3]]
        # expect(json['discussions'][0]['read_items_count']).to eq 2
      end
    end
  end

  describe 'close' do
    it 'allows admins to close a thread' do
      sign_in user
      discussion.group.add_admin! user
      post :close, params: { id: discussion.id }
      expect(discussion.reload.closed_at).to be_present
      json = JSON.parse(response.body)
      expect(json.keys).to include 'events'
    end

    it 'does not allow non-admins to close a thread' do
      sign_in another_user
      post :close, params: {id: discussion.id}
      expect(response.status).to eq 403
    end

    it 'does not allow logged out users to close a thread' do
      post :close, params: {id: discussion.id}
      expect(response.status).to eq 403
    end
  end

  describe 'reopen' do
    before { discussion.update(closed_at: 1.day.ago) }

    it 'allows admins to reopen a thread' do
      sign_in user
      discussion.group.add_admin! user
      post :reopen, params: {id: discussion.id}
      expect(discussion.reload.closed_at).to be_blank
      json = JSON.parse response.body
      expect(json.keys).to include 'events'
    end

    it 'does not allow non-admins to reopen a thread' do
      sign_in another_user
      post :reopen, params: {id: discussion.id}
      expect(response.status).to eq 403
    end

    it 'does not allow logged out users to reopen a thread' do
      post :reopen, params: {id: discussion.id}
      expect(response.status).to eq 403
    end
  end

  describe 'pin' do
    it 'allows admins to pin a thread' do
      sign_in user
      discussion.group.add_admin! user
      post :pin, params: { id: discussion.id }
      expect(discussion.reload.pinned).to eq true
    end

    it 'allows admins to unpin a thread' do
      sign_in user
      discussion.group.add_admin! user
      discussion.update(pinned: true)
      post :pin, params: { id: discussion.id }
      expect(discussion.reload.pinned).to eq false
    end

    it 'does not allow non-admins to pin a thread' do
      sign_in another_user
      post :pin, params: { id: discussion.id }
      expect(response.status).to eq 403
    end

    it 'does not allow logged out users to pin a thread' do
      post :pin, params: { id: discussion.id }
      expect(response.status).to eq 403
    end
  end
end
