require 'rails_helper'

describe API::VisitorsController do
  let(:admin) { create :user }
  let(:user) { create :user }
  let(:poll) { create :poll, author: admin, communities: [community] }
  let(:community) { Communities::Email.create }
  let(:visitor) { create :visitor, community: community }
  let(:poll_created_event) { Events::PollCreated.publish!(poll) }
  let(:visitor_params) {{
    name: "Michael Scott",
    email: "michael@dundermifflin.org"
  }}

  describe 'remind' do
    it 'resends an email to a visitor' do
      poll_created_event
      sign_in admin
      expect { post :remind, id: visitor.id, poll_id: poll.id }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(response.status).to eq 200
    end

    it 'does not allow non-admins to remind a visitor' do
      poll_created_event
      sign_in user
      expect { post :remind, id: visitor.id, poll_id: poll.id }.to_not change { ActionMailer::Base.deliveries.count }
      expect(response.status).to eq 403
    end
  end

  describe 'destroy' do
    it 'sets revoked to true on a visitor' do
      poll
      sign_in admin
      delete :destroy, id: visitor.id
      expect(response.status).to eq 200
      expect(visitor.reload.revoked).to eq true
    end

    it 'does not allow non-admins to revoke visitors' do
      poll
      sign_in user
      delete :destroy, id: visitor.id
      expect(response.status).to eq 403
      expect(visitor.reload.revoked).to eq false
    end
  end

  describe 'update' do
    it 'updates the name and email of a visitor' do
      cookies[:participation_token] = visitor.participation_token
      post :update, id: visitor.id, visitor: visitor_params
      expect(response.status).to eq 200
      expect(visitor.reload.name).to eq visitor_params[:name]
      expect(visitor.email).to eq visitor_params[:email]
    end

    it 'does not update the participation token' do
      cookies[:participation_token] = visitor.participation_token
      visitor_params[:participation_token] = "new_token"
      expect { post :update, id: visitor.id, visitor: visitor_params }.to_not change { visitor.reload.participation_token }
      expect(response.status).to eq 400
    end

    it 'does not allow users other than the visitor to update itself' do
      sign_in admin
      expect { post :update, id: visitor.id, visitor: visitor_params }.to_not change { visitor.reload.participation_token }
      expect(response.status).to eq 403
    end

    it 'does not allow other visitors to update a visitor' do
      cookies[:participation_token] = "abcd"
      expect { post :update, id: visitor.id, visitor: visitor_params }.to_not change { visitor.reload.participation_token }
      expect(response.status).to eq 403
    end
  end
end
