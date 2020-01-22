require 'rails_helper'
describe API::DiscussionsController do

  let(:subgroup) { create :formal_group, parent: group }
  let(:another_group) { create :formal_group }
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :formal_group }
  let(:discussion) { create_discussion group: group }
  let(:poll) { create :poll, discussion: discussion }
  let(:reader) { DiscussionReader.for(user: user, discussion: discussion) }
  let(:another_discussion) { create_discussion }
  let(:comment) { create :comment, discussion: discussion}
  let(:new_comment) { build(:comment, discussion: discussion) }
  let(:discussion_params) {{
    title: 'Did Charlie Bite You?',
    description: 'From the dawn of internet time...',
    group_id: group.id,
    private: true
  }}

  def create_discussion(**args)
    discussion = create :discussion, **args
    DiscussionService.create(discussion: discussion, actor: discussion.author)
    discussion
  end

  before do
    CommentService.create(comment: comment, actor: comment.author)
    group.add_admin! user
  end

  describe 'tags' do
    it 'fetches discussions by tag' do
      tag = Tag.create(group: discussion.group, name: 'some tag', color: '#333')
      dtag = DiscussionTag.create(tag: tag, discussion: discussion)
      get :tags, params: { id: tag.id }
      expect(response.status).to eq 200
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

    describe 'guest threads' do
      it 'displays guest threads' do
        DiscussionService.create(discussion: another_discussion, actor: another_discussion.author)
        sign_in user
        another_discussion.guest_group.add_member! user
        DiscussionReader.for(user: user, discussion: another_discussion).set_volume! :normal
        get :dashboard
        json = JSON.parse(response.body)
        discussion_ids = json['discussions'].map { |d| d['id'] }
        expect(discussion_ids).to include another_discussion.id
      end
    end

    describe 'filtering' do
      let(:subgroup_discussion) { create_discussion group: subgroup }
      let(:muted_discussion) { create_discussion group: group }
      let(:old_discussion) { create_discussion group: group, created_at: 4.months.ago, last_activity_at: 4.months.ago }
      let(:motionless_discussion) { create_discussion group: group }

      before do
        sign_in user
        another_group.add_member! user
        subgroup.add_member! user
        discussion.reload
        [subgroup_discussion, muted_discussion, old_discussion, motionless_discussion].each do |d|
          DiscussionService.create(discussion: d, actor: d.author)
        end
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
        get :dashboard, params: { per: 2 }
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

      it 'displays discussion to guest group members' do
        discussion.group.memberships.find_by(user: user).destroy
        discussion.guest_group.add_member!(user)
        get :show, params: { id: discussion.key }
        json = JSON.parse(response.body)

        expect(response.status).to eq 200
        expect(json['discussions'][0]['id']).to eq discussion.id
      end

      it 'returns the reader fields' do
        DiscussionReader.for(user: user, discussion: discussion).update(volume: :mute)
        get :show, params: { id: discussion.key }
        json = JSON.parse(response.body)
        expect(json['discussions'][0]['discussion_reader_volume']).to eq "mute"
      end
    end

    context 'logged out' do
      let(:public_discussion) { create_discussion private: false }
      let(:private_discussion) { create_discussion private: true }

      before do
        [public_discussion, private_discussion].each do |d|
          DiscussionService.create(discussion: d, actor: d.author)
        end
      end

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
        destination_group.add_member! user
        source_group = discussion.group
        patch :move, params: { id: discussion.id, group_id: destination_group.id }, format: :json

        # Discussion belongs to new group
        # The eventable of the event is the old group
        expect(discussion.reload.group).to eq destination_group
      end
    end
  end

  describe 'index' do
    let(:another_discussion)    { create_discussion group: another_group }

    before do
      discussion; another_discussion
    end

    context 'logged out' do
      let!(:public_discussion) { create_discussion private: false }
      let!(:private_discussion) { create_discussion private: true }

      before do
        [public_discussion, private_discussion].each do |d|
          DiscussionService.create(discussion: d, actor: d.author)
        end
      end

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
          cant_see_me = create_discussion
          get :index, params: { group_id: group.id }, format: :json
          json = JSON.parse(response.body)
          discussions = json['discussions'].map { |v| v['id'] }
          expect(discussions).to_not include cant_see_me.id
        end

        it 'can display content from a specified public group' do
          public_group = create :formal_group, discussion_privacy_options: :public_only, is_visible_to_public: true
          can_see_me = create_discussion(group: public_group, private: false)
          get :index, params: { group_id: public_group.id }, format: :json
          json = JSON.parse(response.body)
          discussions = json['discussions'].map { |v| v['id'] }
          expect(discussions).to include can_see_me.id
        end

        it 'responds to a since parameter' do
          four_months_ago = create_discussion(group: group, created_at: 4.months.ago, last_activity_at: 4.months.ago)
          two_months_ago = create_discussion(group: group, created_at: 2.months.ago, last_activity_at: 2.months.ago)
          get :index, params: { group_id: group.id, since: 3.months.ago }, format: :json
          json = JSON.parse(response.body)
          discussions = json['discussions'].map { |v| v['id'] }
          expect(discussions).to include two_months_ago.id
          expect(discussions).to_not include four_months_ago.id
        end

        it 'responds to an until parameter' do
          four_months_ago = create_discussion(group: group, created_at: 4.months.ago, last_activity_at: 4.months.ago)
          two_months_ago = create_discussion(group: group, created_at: 2.months.ago, last_activity_at: 2.months.ago)
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
        expect(response.status).to eq 200
        expect(reader.reload.volume.to_sym).to eq :mute
      end
    end

    context 'failure' do
      it 'does not update a reader' do
        reader = DiscussionReader.for(user: user, discussion: another_discussion)
        reader.update volume: :loud
        put :set_volume, params: { id: another_discussion.id, volume: :mute }, format: :json
        expect(response.status).not_to eq 200
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
        expect(response.status).to eq 200
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
        expect(JSON.parse(response.body)['exception']).to include 'ActionController::UnpermittedParameters'
      end

      it "responds with an error when the user is unauthorized" do
        sign_in another_user
        put :update, params: { id: discussion.id, discussion: discussion_params }
        expect(JSON.parse(response.body)['exception']).to include 'CanCan::AccessDenied'
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
        expect(response.status).to eq 200
        expect(Discussion.last).to be_present
      end

      it 'doesnt email everyone' do
        expect { post :create, params: { discussion: discussion_params }, format: :json }.to_not change { ActionMailer::Base.deliveries.count }
      end

      it 'emails mentioned users' do
        group.add_member! another_user
        discussion_params[:description] = "Hello @#{another_user.username}!"
        expect { post :create, params: { discussion: discussion_params }, format: :json }.to change { ActionMailer::Base.deliveries.count }.by(1)
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
    end

    context 'failures' do
      it "responds with an error when there are unpermitted params" do
        discussion_params[:dontmindme] = 'wild wooly byte virus'
        post :create, params: { discussion: discussion_params }
        expect(JSON.parse(response.body)['exception']).to include 'ActionController::UnpermittedParameters'
      end

      it "responds with an error when the user is unauthorized" do
        sign_in another_user
        post :create, params: { discussion: discussion_params }
        expect(JSON.parse(response.body)['exception']).to include 'CanCan::AccessDenied'
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

      # it 'responds with reader fields' do
      #   # also testing accumulation
      #   new_comment.discussion = discussion
      #   CommentService.create(comment: new_comment, actor: user)
      #   patch :mark_as_read, params: { id: discussion.id, ranges: "2-2" }
      #   patch :mark_as_read, params: { id: discussion.id, ranges: "3-3" }
      #   json = JSON.parse(response.body)
      #   reader.reload
      #
      #   expect(json['discussions'][0]['id']).to eq discussion.id
      #   expect(json['discussions'][0]['discussion_reader_id']).to eq reader.id
      #   expect(json['discussions'][0]['read_ranges']).to eq [[2,3]]
      #   # expect(json['discussions'][0]['read_items_count']).to eq 2
      # end
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

  describe 'fork' do
    let(:user) { create :user }
    let(:another_user) { create :user }
    let(:group) { create :formal_group }
    let!(:discussion) { create_discussion group: group }
    let(:target_event) { create :event, discussion: discussion, kind: :new_comment, eventable: create(:comment, discussion: discussion), sequence_id: 2 }
    let(:another_event) { create :event, discussion: discussion, kind: :new_comment, eventable: create(:comment, discussion: discussion), sequence_id: 3 }
    let(:alien_comment) { create(:comment) }
    let!(:alien_comment_event) { CommentService.create(comment: alien_comment, actor: alien_comment.author ) }
    let(:fork_params) {{
      title: "A forked title",
      group_id: group.id,
      description: "A forked description",
      private: true,
      forked_event_ids: [target_event.id, another_event.id]
    }}
    let(:alien_fork_params) {{
      title: "A forked title",
      group_id: group.id,
      description: "A forked description",
      private: true,
      forked_event_ids: [target_event.id, alien_comment_event.id, another_event.id]
    }}

    before { group.add_admin! user }

    it 'forks a thread' do
      sign_in user
      expect { post :fork, params: { discussion: fork_params } }.to change { Discussion.count }.by(1)
      expect(response.status).to eq 200

      new_discussion = Discussion.last
      expect(new_discussion.items).to include target_event
      expect(new_discussion.items).to include another_event
      expect(new_discussion.items).not_to include alien_comment_event
      expect(new_discussion.title).to eq fork_params[:title]

      items = discussion.reload.items
      expect(items).to_not include target_event
      expect(items).to_not include another_event

      expect(target_event.reload.eventable.discussion_id).to eq new_discussion.id
      expect(another_event.reload.eventable.discussion_id).to eq new_discussion.id

      forked_event = items.find_by(kind: :discussion_forked)
      expect(forked_event).to be_present
      expect(forked_event.sequence_id).to eq 2
    end

    it 'transfers read state from old discussion readers' do
      event4 = create :event, discussion: discussion, kind: :new_comment, eventable: create(:comment, discussion: discussion), sequence_id: 4
      event5 = create :event, discussion: discussion, kind: :new_comment, eventable: create(:comment, discussion: discussion), sequence_id: 5
      event6 = create :event, discussion: discussion, kind: :new_comment, eventable: create(:comment, discussion: discussion), sequence_id: 6
      reader = create :discussion_reader, discussion: discussion, user: user, read_ranges_string: '4-6'
      another_reader = create :discussion_reader, discussion: discussion, user: another_user, read_ranges_string: '2-3,5-6'
      fork_params[:forked_event_ids] = [target_event.id, event4.id, event5.id]

      sign_in user

      #the fork post creates a discussion and reports success, the fork is performed by the signed in user
      expect { post :fork, params: { discussion: fork_params } }.to change { Discussion.count }.by(1)
      expect(response.status).to eq 200

      #the created discussion has two discussion readers (those created on the original discussion)
      d = Discussion.last
      # expect(d.discussion_readers.count).to eq 3

      #the discussion reader is that of the user and its discussion is that which was made it has read ranges representing the entirety for the user
      dr = DiscussionReader.find_by(user: user, discussion: d)
      expect(dr).to be_present
      expect(dr.read_ranges_string).to eq '2-2,4-5'

      #the other user hadnt read event 4 so they should not have read it
      dr2 = DiscussionReader.find_by(user: another_user, discussion: d)
      expect(dr2).to be_present
      expect(dr2.read_ranges_string).to eq '2-2,5-5'
    end

    it 'does not allow non admins to fork a thread' do
      sign_in another_user
      post :fork, params: { discussion: fork_params }
      expect(response.status).to eq 403
    end

    it 'does not move alien comment events' do
      sign_in user
      expect { post :fork, params: { discussion: alien_fork_params } }.to change { Discussion.count }.by(0)
      expect(response.status).to eq 403
    end
  end

  describe 'move_comments' do
    let(:user) { create :user }
    let(:another_user) { create :user }
    let(:group) { create :formal_group }
    let!(:source_discussion) { create_discussion group: group }
    let!(:target_discussion) { create_discussion group: group }

    let(:first_comment) { create(:comment, discussion: source_discussion) }
    let(:second_comment) { create(:comment, discussion: source_discussion, parent: first_comment) }
    let(:third_comment) { create(:comment, discussion: source_discussion) }
    let(:alien_comment) { create(:comment) }

    let!(:first_comment_event) { CommentService.create(comment: first_comment, actor: first_comment.author ) }
    let!(:second_comment_event) { CommentService.create(comment: second_comment, actor: second_comment.author ) }
    let!(:third_comment_event) { CommentService.create(comment: third_comment, actor: third_comment.author ) }
    let!(:alien_comment_event) { CommentService.create(comment: alien_comment, actor: alien_comment.author ) }


    let(:existing_comment) { create(:comment, discussion: target_discussion) }

    let(:existing_comment_event) { CommentService.create(comment: existing_comment, actor: existing_comment.author) }

    let(:move_comments_params) {{
      forked_event_ids: [first_comment_event.id, second_comment_event.id]
    }}

    before do
      group.add_admin! user
      sign_in user
    end

    it 'moves children when moving parents from a discussion to an empty one' do
      patch :move_comments, params: { id: target_discussion.id, forked_event_ids: [first_comment_event.id] }
      expect(response.status).to eq 200

      expect(target_discussion.reload.items).to include first_comment_event
      expect(target_discussion.reload.items).to include second_comment_event

      expect(source_discussion.reload.items).to include third_comment_event

      expect(first_comment_event.reload.eventable.discussion_id).to eq target_discussion.id
      expect(second_comment_event.reload.eventable.discussion_id).to eq target_discussion.id
      expect(third_comment_event.reload.eventable.discussion_id).to eq source_discussion.id

      expect(first_comment_event.reload.parent_id).to eq target_discussion.created_event.id
      expect(second_comment_event.reload.parent_id).to eq first_comment_event.id

      expect(first_comment_event.reload.depth).to eq 1
      expect(second_comment_event.reload.depth).to eq 2

      expect(first_comment.reload.parent_id).to eq nil
      expect(second_comment.reload.parent_id).to eq first_comment.id

      expect(first_comment_event.reload.position).to eq 1
      expect(second_comment_event.reload.position).to eq 1
      expect(third_comment_event.reload.position).to eq 1

      expect(first_comment_event.reload.sequence_id).to eq 1
      expect(second_comment_event.reload.sequence_id).to eq 2
      expect(third_comment_event.reload.sequence_id).to eq 3
    end

    it 'moves reply comment only from a discussion to an empty one' do
      patch :move_comments, params: { id: target_discussion.id, forked_event_ids: [second_comment_event.id]}
      expect(response.status).to eq 200

      expect(source_discussion.reload.items).to include first_comment_event
      expect(target_discussion.reload.items).to include second_comment_event
      expect(source_discussion.reload.items).to include third_comment_event

      expect(first_comment.reload.discussion_id).to eq source_discussion.id
      expect(second_comment.reload.discussion_id).to eq target_discussion.id
      expect(third_comment.reload.discussion_id).to eq source_discussion.id

      expect(first_comment_event.reload.parent_id).to eq source_discussion.created_event.id
      expect(second_comment_event.reload.parent_id).to eq target_discussion.created_event.id

      expect(first_comment_event.reload.depth).to eq 1
      expect(second_comment_event.reload.depth).to eq 1

      expect(first_comment.reload.parent_id).to eq nil
      expect(second_comment.reload.parent_id).to eq nil

      expect(first_comment_event.reload.position).to eq 1
      expect(second_comment_event.reload.position).to eq 1
      expect(third_comment_event.reload.position).to eq 2

      expect(first_comment_event.reload.sequence_id).to eq 1
      expect(second_comment_event.reload.sequence_id).to eq 1
      expect(third_comment_event.reload.sequence_id).to eq 3
    end

    it 'moves reply comment only from a discussion to a non empty one' do
      existing_comment_event
      patch :move_comments, params: { id: target_discussion.id, forked_event_ids: [second_comment_event.id]}
      expect(response.status).to eq 200

      expect(source_discussion.reload.items).to include first_comment_event
      expect(target_discussion.reload.items).to include second_comment_event
      expect(source_discussion.reload.items).to include third_comment_event

      expect(first_comment.reload.discussion_id).to eq source_discussion.id
      expect(second_comment.reload.discussion_id).to eq target_discussion.id
      expect(third_comment.reload.discussion_id).to eq source_discussion.id

      expect(first_comment_event.reload.parent_id).to eq source_discussion.created_event.id
      expect(second_comment_event.reload.parent_id).to eq target_discussion.created_event.id

      expect(first_comment_event.reload.depth).to eq 1
      expect(second_comment_event.reload.depth).to eq 1

      expect(first_comment.reload.parent_id).to eq nil
      expect(second_comment.reload.parent_id).to eq nil

      expect(existing_comment_event.reload.position).to eq 1
      expect(first_comment_event.reload.position).to eq 1
      expect(second_comment_event.reload.position).to eq 2
      expect(third_comment_event.reload.position).to eq 2


      expect(existing_comment_event.reload.sequence_id).to eq 1
      expect(first_comment_event.reload.sequence_id).to eq 1
      expect(second_comment_event.reload.sequence_id).to eq 2
      expect(third_comment_event.reload.sequence_id).to eq 3
    end

    describe 'move poll, stance, outcome' do
      let!(:poll)    { create(:poll, discussion: source_discussion, group: source_discussion.group)}
      let!(:stance)  { create(:stance, poll: poll) }
      let!(:outcome) { create(:outcome, poll: poll) }

      let!(:poll_event) { PollService.create(poll: poll, actor: user) }
      let!(:stance_event) { StanceService.create(stance: stance, actor: user) }
      let(:outcome_event) { OutcomeService.create(outcome: outcome, actor: user) }

      before do
        poll.update(closed_at: Time.now)
        outcome_event
      end

      it 'moves stances and outcomes when polls from a discussion to an empty one' do
        patch :move_comments, params: { id: target_discussion.id, forked_event_ids: [poll_event.id] }
        expect(response.status).to eq 200

        expect(target_discussion.reload.items).to include poll_event
        expect(target_discussion.reload.items).to include stance_event
        expect(target_discussion.reload.items).to include outcome_event

        expect(poll_event.reload.eventable.discussion_id).to eq target_discussion.id
        expect(poll_event.reload.eventable.group_id).to eq target_discussion.group_id
        expect(poll_event.reload.parent_id).to eq target_discussion.created_event.id

        expect(poll_event.reload.depth).to eq 1
        expect(stance_event.reload.depth).to eq 2
        expect(outcome_event.reload.depth).to eq 2
      end
    end

    it 'does not move events that are not part of the source discussion' do
      patch :move_comments, params: { id: target_discussion.id, forked_event_ids: [first_comment_event.id, alien_comment_event.id]}
      expect(response.status).to eq 200
      expect(alien_comment_event.reload.discussion_id).not_to eq target_discussion.id
    end

    it 'access denied for moving comments where you are not an admin of the source discussion' do
      patch :move_comments, params: { id: target_discussion.id, forked_event_ids: [alien_comment_event.id]}
      expect(response.status).to eq 403
    end
    it 'access denied for moving comments where you are not an admin of the target discussion' do
      patch :move_comments, params: { id: alien_comment_event.discussion_id, forked_event_ids: [first_comment_event.id]}
      expect(response.status).to eq 403
    end
  end

end
