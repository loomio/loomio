require 'rails_helper'

describe MergeUsersController do
  let(:source_user) { create :user }
  let(:target_user) { create :user }

  before do
    MergeUsersService.prep_for_merge!(source_user: source_user, target_user: target_user)
  end
  
  it 'merge happy' do
    get :merge, params: {
      source_id: source_user.id,
      target_id: target_user.id,
      hash: MergeUsersService.build_merge_hash(source_user: source_user, target_user: target_user)
    }
    expect(response.status).to eq 200
  end

  it 'merge sad' do
    get :merge, params: {
      source_id: source_user.id,
      target_id: target_user.id,
      hash: 'invalid hash',
    }
    expect(response.status).to eq 422
  end
end
