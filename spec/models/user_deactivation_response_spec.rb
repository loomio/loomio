require 'rails_helper'

describe UserDeactivationResponse do
  let(:user) { create(:user) }
  let(:deactivate_params) { { deactivation_response: 'They took our joarbs!' } }

  it 'creates a response on user deactivation' do
    expect { UserService.deactivate(user: user, actor: user, params: deactivate_params) }.to change { UserDeactivationResponse.count }.by(1)
    expect(UserDeactivationResponse.last.body).to eq deactivate_params[:deactivation_response]
  end
end
