require 'rails_helper'
describe API::EventsController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group, private: false }
  let(:another_discussion) { create :discussion, group: group, private: true }
  let(:reader) { DiscussionReader.for(user: user, discussion: discussion) }

  before do
    group.add_admin! user
    group.add_member! another_user
  end

  describe 'pinning' do
    before { sign_in user }

    it 'pin event' do
      DiscussionService.create(discussion: discussion, actor: user)
      event = CommentService.create(comment: create(:comment, discussion: discussion), actor: user)
      patch :pin, params: {id: event.id}
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json['events'].map { |d| d['id'] }).to include event.id
      expect(event.reload.pinned).to be true
    end

    context 'unpin event' do
    end
    context 'not permitted' do
    end
  end

  describe 'index' do

    before { sign_in user }

    context 'success' do

      before do
        @event         = CommentService.create(comment: build(:comment, discussion: discussion), actor: user)
        @another_event = CommentService.create(comment: build(:comment, discussion: another_discussion), actor: user)
      end

      context 'logged out' do
        before { @controller.stub(:current_user).and_return(LoggedOutUser.new) }

        it 'returns a list of events for public discussions' do
          get :index, params: { discussion_id: discussion.id }, format: :json
          json = JSON.parse(response.body)
          event_ids = json['events'].map { |d| d['id'] }
          expect(event_ids).to include @event.id
          expect(event_ids).to_not include @another_event.id
        end

        it 'responds with forbidden for private discussions' do
          get :index, params: { discussion_id: another_discussion.id }, format: :json
          expect(response.status).to eq 403
        end
      end

      # context "remove from thread" do
      #   it 'removes discussion_id if permitted' do
      #     @edited_event = Events::DiscussionEdited.publish!(discussion, user)
      #     expect(@edited_event.discussion_id).to be discussion.id
      #     patch :remove_from_thread, params: { id: @edited_event.id }
      #     json = JSON.parse(response.body)
      #     expect(json.keys).to include *(%w[events])
      #     result_event = json['events'].last
      #     expect(result_event['discussion_id']).to be nil
      #     expect(result_event['id']).to be @edited_event.id
      #   end
      #
      #   it 'denys if not permitted' do
      #     patch :remove_from_thread, params: { id: @event.id }
      #     expect(response.status).to eq 403
      #   end
      # end

      it 'returns events filtered by discussion' do
        get :index, params: { discussion_id: discussion.id }, format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[events])
        event_ids = json['events'].map { |v| v['id'] }
        expect(event_ids).to include @event.id
        expect(event_ids).to_not include @another_event.id
      end

      # later on, not now
      # it 'excludes specific sequence ids given ranges' do
      #   ranges_str = RangeSet.serialize RangeSet.to_ranges(@event.sequence_id)
      #   get :index, discussion_id: discussion.id, exclude_sequence_ids: ranges_str
      #   json = JSON.parse(response.body)
      #   event_ids = json['events'].map { |v| v['id'] }
      #   expect(event_ids).to_not include @event.id
      # end

      it 'responds with a discussion with a reader' do
        get :index, params: { discussion_id: discussion.id }, format: :json
        json = JSON.parse(response.body)
        expect(json['discussions'][0]['discussion_reader_id']).to be_present
      end

    end

    context 'with comment' do
      before do
        @event = CommentService.create(comment: build(:comment, discussion: discussion), actor: user)
      end

      it 'returns events beginning with a given comment id' do
        get :comment, params: { discussion_id: discussion.id, comment_id: @event.eventable.id }
        json = JSON.parse(response.body)
        event_ids = json['events'].map { |v| v['id'] }
        expect(event_ids).to include @event.id
      end

      it 'returns 404 when comment not found' do
        get :comment, params: { discussion_id: discussion.id, comment_id: nil }
        expect(response.status).to eq 404
      end
    end

    context 'with parent_id' do
      before do
        @discussion_event = DiscussionService.create(discussion: discussion, actor: user)
        @parent_comment =  build(:comment, discussion: discussion)
        @parent_event = CommentService.create(comment: @parent_comment, actor: user)
        @child_event = CommentService.create(comment: build(:comment, discussion: discussion, parent: @parent_comment), actor: user)
        @unrelated_event = CommentService.create(comment: build(:comment, discussion: discussion), actor: user)
      end

      it 'returns events with given parent_id' do
        get :index, params: { discussion_id: discussion.id, parent_id: @parent_event.id }
        json = JSON.parse(response.body)
        event_ids = json['events'].map { |v| v['id'] }
        expect(event_ids).to include @child_event.id
        expect(event_ids).to include @parent_event.id
        expect(event_ids).to_not include @unrelated_event.id
      end
    end

    context 'paging' do

      before do
        5.times { CommentService.create(comment: build(:comment, discussion: discussion), actor: user) }
      end

      it 'responds to a limit parameter' do
        get :index, params: { discussion_id: discussion.id, per: 3 }
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[events])
        event_ids = json['events'].map { |v| v['id'] }
        # expect(event_ids.count).to eq 4 # one more for the parent event
      end

      it 'responds to a from parameter' do
        get :index, params: { discussion_id: discussion.id, from: 3 }
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[events])
        sequence_ids = json['events'].map { |v| v['sequence_id'] }.compact
        expect(sequence_ids.sort).to eq [3,4,5]
      end

      context 'with deleted events' do
        it 'accounts for deleted sequence ids' do
          Event.find_by_sequence_id(3).destroy!
          get :index, params: { discussion_id: discussion.id, from: 0, per: 3 }
          json = JSON.parse(response.body)
          expect(json.keys).to include *(%w[events])
          sequence_ids = json['events'].map { |v| v['sequence_id'] }.compact
          expect(sequence_ids.sort).to eq [1,2,4]
        end
      end
    end
  end
end
