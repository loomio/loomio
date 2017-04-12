
require 'rails_helper'

describe PollsController do
  let(:user) { create :user }
  let(:group) { create :group, is_visible_to_public: true }
  let(:discussion) { create :discussion, private: false, group: group }
  let(:poll) { create :poll, author: user }
  let(:another_poll) { create :poll }
  let(:closed_poll) { create :poll, author: user, closed_at: 1.day.ago }

  describe 'show' do
    it 'sets metadata for public polls' do
      poll.update(anyone_can_participate: true)
      get :show, key: poll.key
      expect(assigns(:metadata)[:title]).to eq poll.title
    end

    it 'does not set metadata for private polls' do
      get :show, key: poll.key
      expect(assigns(:metadata)[:title]).to be_nil
    end
  end

  describe 'share' do
    it 'allows the author to share a poll' do
      sign_in user
      get :share, key: poll.key
      expect(response.status).to eq 200
    end

    it 'allows a group admin to share a poll' do
      poll.update(discussion: discussion)
      sign_in poll.group.admins.first
      get :share, key: poll.key
      expect(response.status).to eq 200
    end

    it 'does not allow other users to share the poll' do
      sign_in create(:user)
      get :share, key: poll.key
      expect(response.status).to eq 302
    end

    it 'does not allow visitors to share the poll' do
      get :share, key: poll.key
      expect(response.status).to eq 302
    end
  end
end
