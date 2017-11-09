require 'rails_helper'
describe API::EventsController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :formal_group }
  let(:discussion) { create :discussion, group: group, private: false }
  let(:another_discussion) { create :discussion, group: group, private: true }
  let(:reader) { DiscussionReader.for(user: user, discussion: discussion) }

  before do
    group.add_admin! user
    group.add_member! another_user
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
          get :index, discussion_id: discussion.id, format: :json
          json = JSON.parse(response.body)
          event_ids = json['events'].map { |d| d['id'] }
          expect(event_ids).to include @event.id
          expect(event_ids).to_not include @another_event.id
        end

        it 'responds with forbidden for private discussions' do
          get :index, discussion_id: another_discussion.id, format: :json
          expect(response.status).to eq 403
        end
      end

      it 'returns events filtered by discussion' do
        get :index, discussion_id: discussion.id, format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[events])
        event_ids = json['events'].map { |v| v['id'] }
        expect(event_ids).to include @event.id
        expect(event_ids).to_not include @another_event.id
      end

      it 'excludes specific sequence ids given ranges' do
        ranges_str = RangeSet.serialize RangeSet.to_ranges(@event.sequence_id)
        get :index, discussion_id: discussion.id, exclude_sequence_ids: ranges_str
        json = JSON.parse(response.body)
        event_ids = json['events'].map { |v| v['id'] }
        expect(event_ids).to_not include @event.id
      end

      it 'responds with a discussion with a reader' do
        get :index, discussion_id: discussion.id, format: :json
        json = JSON.parse(response.body)
        expect(json['discussions'][0]['discussion_reader_id']).to be_present
      end

    end

    context 'with comment' do
      before do
        @early_event = CommentService.create(comment: build(:comment, discussion: discussion), actor: user)
        @later_event = CommentService.create(comment: build(:comment, discussion: discussion), actor: user)
      end

      it 'returns events beginning with a given comment id' do
        get :index, discussion_id: discussion.id, format: :json, comment_id: @later_event.eventable.id
        json = JSON.parse(response.body)
        event_ids = json['events'].map { |v| v['id'] }
        expect(event_ids).to include @later_event.id
        expect(event_ids).to_not include @early_event.id
      end

      it 'returns events normally when no comment id is passed' do
        get :index, discussion_id: discussion.id, format: :json, comment_id: nil
        json = JSON.parse(response.body)
        event_ids = json['events'].map { |v| v['id'] }
        expect(event_ids).to include @later_event.id
        expect(event_ids).to include @early_event.id
      end

      it 'returns events normally when a nonexistent comment id is passed' do
        get :index, discussion_id: discussion.id, format: :json, comment_id: -2
        json = JSON.parse(response.body)
        event_ids = json['events'].map { |v| v['id'] }
        expect(event_ids).to include @later_event.id
        expect(event_ids).to include @early_event.id
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
        get :index, discussion_id: discussion.id, parent_id: @parent_event.id
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
        get :index, discussion_id: discussion.id, per: 3
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[events])
        event_ids = json['events'].map { |v| v['id'] }
        expect(event_ids.count).to eq 3
      end

      it 'responds to a from parameter' do
        get :index, discussion_id: discussion.id, from: 3
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[events])
        sequence_ids = json['events'].map { |v| v['sequence_id'] }
        expect(sequence_ids.sort).to eq [3,4,5]
      end

      context 'with deleted events' do
        it 'accounts for deleted sequence ids' do
          Event.find_by_sequence_id(3).destroy!
          get :index, discussion_id: discussion.id, from: 0, per: 3
          json = JSON.parse(response.body)
          expect(json.keys).to include *(%w[events])
          sequence_ids = json['events'].map { |v| v['sequence_id'] }
          expect(sequence_ids.sort).to eq [1,2,4]
        end

      end
    end
  end

end
