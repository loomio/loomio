require 'rails_helper'
describe API::EventsController do

  let(:user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:another_discussion) { create :discussion, group: group }

  before do
    group.admins << user
    sign_in user
  end

   describe 'index' do

    before do
      @event         = CommentService.create(comment: build(:comment, discussion: discussion), actor: user)
      @another_event = CommentService.create(comment: build(:comment, discussion: another_discussion), actor: user)
    end

    context 'success' do
      it 'returns events filtered by discussion' do
        get :index, discussion_id: discussion.id, format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[events])
        events = json['events'].map { |v| v['id'] }
        expect(events).to include @event.id
        expect(events).to_not include @another_event.id
      end
    end
  end

end
