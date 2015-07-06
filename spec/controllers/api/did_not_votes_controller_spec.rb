require 'rails_helper'

describe API::DidNotVotesController do

  let(:user)                  { create :user }
  let(:group)                 { create :group }
  let(:discussion)            { create :discussion, group: group }
  let(:motion)                { create :motion, discussion: discussion }

  before do
    motion
    stub_request(:post, "http://localhost:9292/faye").to_return(status: 200)
    group.admins << user
    sign_in user
    MotionService.close(motion)
  end

  describe 'index' do

    context 'success' do
      it 'returns did not votes for a motion' do
        get :index, motion_id: motion.id, format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[did_not_votes])
      end
    end
  end
end
