require 'rails_helper'
describe API::DiscussionsController do

  let(:subgroup) { create :group, parent: group }
  let(:another_group) { create :group }
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:poll) { create :poll, discussion: discussion }
  let(:reader) { DiscussionReader.for(user: user, discussion: discussion) }
  let(:another_discussion) { create :discussion }
  let(:comment) { create :comment, discussion: discussion}
  let(:new_comment) { build(:comment, discussion: discussion) }
  let(:proposal) { create :motion, discussion: discussion, author: user }
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
      get :dashboard, access_token: access_token.token
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      discussion_ids = json['discussions'].map { |d| d['id'] }
      expect(discussion_ids).to include discussion.id
      expect(discussion_ids).to_not include another_discussion.id
    end

    it 'returns forbidden if the access token is not found' do
      get :dashboard, access_token: "blargety blarg"
      expect(response.status).to eq 403
    end

    it 'returns unauthorized if the access token has been revoked' do
      access_token.update(revoked_at: 2.days.ago)
      get :dashboard, access_token: access_token.token
      expect(response.status).to eq 401
    end

    it 'returns unauthorized if the access token is expired' do
      access_token.update(expires_in: 0)
      get :dashboard, access_token: access_token.token
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
        reader.viewed!(reader.discussion.last_activity_at)
        group.add_member! another_user
      end

      it 'returns unread threads' do
        CommentService.create(comment: new_comment, actor: another_user)
        get :inbox
        json = JSON.parse(response.body)
        discussion_ids = json['discussions'].map { |d| d['id'] }
        expect(discussion_ids).to include discussion.id
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
      let(:participating_discussion) { create :discussion, group: group }
      let(:subgroup_discussion) { create :discussion, group: subgroup }
      let(:muted_discussion) { create :discussion, group: group }
      let(:starred_discussion) { create :discussion, group: group }
      let(:old_discussion) { create :discussion, group: group, created_at: 4.months.ago, last_activity_at: 4.months.ago }
      let(:motionless_discussion) { create :discussion, group: group }

      before do
        sign_in user
        another_group.add_member! user
        subgroup.add_member! user
        discussion.reload
        DiscussionReader.for(user: user, discussion: muted_discussion).set_volume! 'mute'
        DiscussionReader.for(user: user, discussion: starred_discussion).update starred: true
      end

      it 'does not return muted discussions by default' do
        muted_discussion.reload
        get :dashboard
        json = JSON.parse(response.body)
        ids = json['discussions'].map { |v| v['id'] }
        expect(ids).to_not include muted_discussion.id
      end

      it 'can filter by participating' do
        CommentService.create actor: user, comment: build(:comment, discussion: participating_discussion)
        get :dashboard, filter: :show_participating
        json = JSON.parse(response.body)
        ids = json['discussions'].map { |v| v['id'] }
        expect(ids).to include participating_discussion.id
        expect(ids).to_not include discussion.id
      end

      it 'can filter by muted' do
        muted_discussion.reload
        get :dashboard, filter: :show_muted
        json = JSON.parse(response.body)
        ids = json['discussions'].map { |v| v['id'] }
        expect(ids).to include muted_discussion.id
        expect(ids).to_not include discussion.id
      end

      it 'can filter since a certain date' do
        old_discussion.reload
        get :dashboard, since: 3.months.ago
        json = JSON.parse(response.body)
        ids = json['discussions'].map { |v| v['id'] }
        expect(ids).to include discussion.id
        expect(ids).to_not include old_discussion.id
      end

      it 'can filter until a certain date' do
        old_discussion.reload
        get :dashboard, until: 3.months.ago
        json = JSON.parse(response.body)
        ids = json['discussions'].map { |v| v['id'] }
        expect(ids).to_not include discussion.id
        expect(ids).to include old_discussion.id
      end

      it 'can limit collection size' do
        get :dashboard, limit: 2
        json = JSON.parse(response.body)
        expect(json['discussions'].count).to eq 2
      end
    end

    describe 'sorting' do
      let(:starred_with_proposal) { create :discussion, group: group, title: 'starred_with_proposal' }
      let(:with_proposal) { create :discussion, group: group, title: 'with_proposal' }
      let(:starred) { create :discussion, group: group, title: 'starred', last_activity_at: 20.days.ago }
      let(:recent) { create :discussion, group: group, last_activity_at: 1.day.ago, title: 'recent' }
      let(:not_recent) { create :discussion, group: group, last_activity_at: 5.days.ago, title: 'not_recent' }

      before do
        sign_in user
        recent; not_recent
      end

      it 'sorts by starred w/ proposals first' do
        DiscussionReader.for(user: user, discussion: starred_with_proposal).update starred: true
        DiscussionReader.for(user: user, discussion: starred).update starred: true
        starred_with_proposal.motions << create(:motion, closing_at: 2.days.from_now)
        with_proposal.motions         << create(:motion, closing_at: 2.days.from_now)
        get :dashboard

        json = JSON.parse(response.body)
        expect(json['discussions'][0]['id']).to eq starred_with_proposal.id
      end

      it 'sorts by proposals second' do
        DiscussionReader.for(user: user, discussion: starred).update starred: true
        with_proposal.motions << create(:motion, closing_at: 2.days.from_now)
        get :dashboard

        json = JSON.parse(response.body)
        expect(json['discussions'][0]['id']).to eq with_proposal.id
      end

      it 'sorts by starred third' do
        DiscussionReader.for(user: user, discussion: starred).update starred: true
        get :dashboard

        json = JSON.parse(response.body)
        expect(json['discussions'][0]['id']).to eq starred.id
      end

      it 'sorts by recent activity fourth' do
        not_recent.update last_activity_at: 10.days.ago
        get :dashboard

        json = JSON.parse(response.body)
        expect(json['discussions'][0]['id']).to eq recent.id
      end
    end
  end

  describe 'show' do
    context 'logged in' do
      before { sign_in user }
      it 'returns the discussion json' do
        proposal
        get :show, id: discussion.key
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[users groups proposals discussions])
        expect(json['discussions'][0].keys).to include *(%w[id key title description last_activity_at created_at updated_at items_count private author_id group_id active_proposal_id])
      end

      it 'returns the reader fields' do
        DiscussionReader.for(user: user, discussion: discussion).update(starred: true)
        get :show, id: discussion.key
        json = JSON.parse(response.body)
        expect(json['discussions'][0]['starred']).to eq true
      end
    end

    context 'logged out' do
      let(:public_discussion) { create :discussion, private: false }
      let(:private_discussion) { create :discussion, private: true }

      it 'returns a public discussions' do
        get :show, id: public_discussion.id, format: :json
        json = JSON.parse(response.body)
        discussion_ids = json['discussions'].map { |d| d['id'] }
        expect(discussion_ids).to_not include private_discussion.id
        expect(discussion_ids).to include public_discussion.id
      end

      it 'returns unauthorized for a private discussion' do
        get :show, id: private_discussion.id, format: :json
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

    it "updates dismissed_at", focus: true do
      patch :dismiss, id: discussion.key
      expect(response.status).to eq 200
      expect(reader.reload.dismissed_at).to be_present
    end
  end

  describe 'mark_as_read' do
    let(:reader) { DiscussionReader.for(user: user, discussion: discussion) }

    context 'signed out' do
      it 'does not attempt to mark discussions as read while logged out' do
        event = CommentService.create(comment: build(:comment, discussion: another_discussion), actor: another_discussion.author)
        patch :mark_as_read, id: discussion.key, sequence_id: 0
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

      it "Marks context/discusion as read" do
        patch :mark_as_read, id: discussion.key, sequence_id: 0
        expect(reader.reload.last_read_at).to eq discussion.reload.last_activity_at
        expect(reader.last_read_sequence_id).to eq 0
        expect(response.status).to eq 200
      end

      it "Marks thread item as read" do
        event = CommentService.create(comment: comment, actor: discussion.author)
        patch :mark_as_read, id: discussion.key, sequence_id: event.reload.sequence_id
        expect(reader.reload.last_read_at).to eq event.created_at
        expect(reader.last_read_sequence_id).to eq 1
        expect(response.status).to eq 200
      end

      it 'does not mark an inaccessible discussion as read' do
        event = CommentService.create(comment: build(:comment, discussion: another_discussion), actor: another_discussion.author)
        patch :mark_as_read, id: another_discussion.key, sequence_id: event.reload.sequence_id
        expect(response.status).to eq 403
        expect(reader.reload.last_read_sequence_id).to eq 0
      end

      it 'responds with reader fields' do
        event = CommentService.create(comment: comment, actor: discussion.author)
        patch :mark_as_read, id: discussion.key, sequence_id: event.reload.sequence_id
        json = JSON.parse(response.body)
        reader.reload

        expect(json['discussions'][0]['discussion_reader_id']).to eq reader.id
        expect(json['discussions'][0]['discussion_reader_volume']).to eq reader.discussion_reader_volume
        expect(json['discussions'][0]['starred']).to eq reader.starred
        expect(json['discussions'][0]['last_read_sequence_id']).to eq reader.last_read_sequence_id
        expect(json['discussions'][0]['participating']).to eq reader.participating
      end
    end
  end

  describe 'move' do
    before { sign_in user }

    context 'success' do
      it 'moves a discussion' do
        destination_group = create :group
        destination_group.users << user
        source_group = discussion.group
        patch :move, id: discussion.id, group_id: destination_group.id, format: :json

        json = JSON.parse(response.body)

        # Discussion belongs to new group
        # The eventable of the event is the old group
        expect(discussion.reload.group).to eq destination_group
        expect(json['groups'].first['id']).to eq source_group.id
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

        it 'can display content from a specified public group' do
          public_group = create :group, discussion_privacy_options: :public_only, is_visible_to_public: true
          can_see_me = create :discussion, group: public_group, private: false
          get :index, group_id: public_group.id, format: :json
          json = JSON.parse(response.body)
          discussions = json['discussions'].map { |v| v['id'] }
          expect(discussions).to include can_see_me.id
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

        it 'responds with active polls' do
          poll
          get :index, group_id: group.id, format: :json
          json = JSON.parse(response.body)
          poll_ids = json['polls'].map { |p| p['id'] }
          expect(poll_ids).to include poll.id
        end
      end
    end
  end

  describe 'star' do
    before { sign_in user }

    context 'success' do
      it 'stars a thread' do
        put :star, id: discussion.id, format: :json
        expect(response).to be_success
        expect(DiscussionReader.for(user: user, discussion: discussion).starred).to eq true
      end
    end

    context 'failure' do
      it 'does not star a thread' do
        put :star, id: another_discussion.id, format: :json
        expect(response).to_not be_success
        expect(DiscussionReader.for(user: user, discussion: another_discussion).starred).to eq false
      end
    end
  end

  describe 'unstar' do
    before { sign_in user }

    context 'success' do
      it 'unstars a thread' do
        reader = DiscussionReader.for(user: user, discussion: discussion)
        reader.update starred: true
        put :unstar, id: discussion.id, format: :json
        expect(response).to be_success
        expect(reader.reload.starred).to eq false
      end
    end

    context 'failure' do
      it 'does not update a reader' do
        reader = DiscussionReader.for(user: user, discussion: another_discussion)
        reader.update starred: true
        put :unstar, id: another_discussion.id, format: :json
        expect(response).not_to be_success
        expect(reader.reload.starred).to eq true
      end
    end
  end

  describe 'set_volume' do
    before { sign_in user }

    context 'success' do
      it 'sets the volume of a thread' do
        reader = DiscussionReader.for(user: user, discussion: discussion)
        reader.update volume: :loud
        put :set_volume, id: discussion.id, volume: :mute, format: :json
        expect(response).to be_success
        expect(reader.reload.volume.to_sym).to eq :mute
      end
    end

    context 'failure' do
      it 'does not update a reader' do
        reader = DiscussionReader.for(user: user, discussion: another_discussion)
        reader.update volume: :loud
        put :set_volume, id: another_discussion.id, volume: :mute, format: :json
        expect(response).not_to be_success
        expect(reader.reload.volume.to_sym).not_to eq :mute
      end
    end
  end

  describe 'update' do
    before { sign_in user }
    let(:attachment) { create(:attachment) }

    context 'success' do
      it "updates a discussion" do
        post :update, id: discussion.id, discussion: discussion_params, format: :json
        expect(response).to be_success
        expect(discussion.reload.title).to eq discussion_params[:title]
      end

      it 'adds attachments' do
        discussion_params[:attachment_ids] = attachment.id
        post :update, id: discussion.id, discussion: discussion_params, format: :json
        expect(discussion.reload.attachments).to include attachment
        json = JSON.parse(response.body)
        attachment_ids = json['attachments'].map { |a| a['id'] }
        expect(attachment_ids).to include attachment.id
      end

      it 'removes attachments' do
        attachment.update(attachable: discussion)
        discussion_params[:attachment_ids] = []
        post :update, id: discussion.id, discussion: discussion_params, format: :json
        expect(discussion.reload.attachments).to be_empty
        json = JSON.parse(response.body)
        attachment_ids = json['attachments'].map { |a| a['id'] }
        expect(attachment_ids).to_not include attachment.id
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
    before { sign_in user }

    context 'success' do
      it "creates a discussion" do
        post :create, discussion: discussion_params, format: :json
        expect(response).to be_success
        expect(Discussion.last).to be_present
      end

      describe 'make_announcement' do
        it 'does not email users for non-announcements' do
          expect { post :create, discussion: discussion_params, format: :json }.to_not change { ActionMailer::Base.deliveries.count }
        end

        it 'makes an announcement' do
          discussion_params[:make_announcement] = true
          expect { post :create, discussion: discussion_params, format: :json }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end
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
          last_activity_at
          created_at
          updated_at
          items_count
          private
          active_proposal_id
          author_id
          group_id
        ])
      end

      describe 'mentioning' do
        it 'mentions appropriate users' do
          group.add_member! another_user
          discussion_params[:description] = "Hello, @#{another_user.username}!"
          expect { post :create, discussion: discussion_params, format: :json }.to change { Event.where(kind: :user_mentioned).count }.by(1)
        end

        it 'does not mention users not in the group' do
          discussion_params[:description] = "Hello, @#{another_user.username}!"
          expect { post :create, discussion: discussion_params, format: :json }.to_not change { Event.where(kind: :user_mentioned).count }
        end
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
