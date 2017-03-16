require 'rails_helper'

describe API::VisitorsController do
  let(:admin) { create :user }
  let(:user) { create :user }
  let!(:poll) { create :poll, author: admin, communities: [community] }
  let(:community) { Communities::Email.create }
  let(:visitor) { create :visitor, community: community }
  let(:new_visitor_params) {{
    community_id: community.id,
    name: "Michael Scott",
    email: "michael@dundermifflin.org"
  }}
  let(:existing_visitor_params) {{
    community_id: visitor.community_id,
    email: visitor.email
  }}

  before { ActionMailer::Base.deliveries = [] }

  describe 'create' do
    it 'creates a new visitor' do
      visitors_count = Visitor.count
      sign_in admin

      expect { post :create, visitor: new_visitor_params }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(Visitor.count).to eq visitors_count + 1
      expect(response.status).to eq 200
      expect(Visitor.last.email).to eq new_visitor_params[:email]
    end

    it 'reinvites a revoked visitor' do
      visitor.update(revoked: true)
      visitors_count = Visitor.count
      sign_in admin

      expect { post :create, visitor: existing_visitor_params }.to_not change { Visitor.count }
      expect(response.status).to eq 200
      expect(visitor.reload.revoked).to eq false
    end

    it 'sends an email to an unrevoked user' do
      visitor.update(revoked: true)
      sign_in admin

      expect { post :create, visitor: existing_visitor_params }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(response.status).to eq 200
    end

    it 'does not allow non-admins to invite a visitor' do
      sign_in user

      expect { post :create, visitor: existing_visitor_params }.to_not change { ActionMailer::Base.deliveries.count }
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
      post :update, id: visitor.id, visitor: new_visitor_params, participation_token: visitor.participation_token
      expect(response.status).to eq 200
      expect(visitor.reload.name).to eq new_visitor_params[:name]
      expect(visitor.email).to eq new_visitor_params[:email]
    end

    it 'does not update the participation token' do
      new_visitor_params[:participation_token] = "new_token"
      expect { post :update, id: visitor.id, visitor: new_visitor_params, participation_token: visitor.participation_token }.to_not change { visitor.reload.participation_token }
      expect(response.status).to eq 400
    end

    it 'does not allow users other than the visitor to update itself' do
      sign_in user
      expect { post :update, id: visitor.id, visitor: new_visitor_params, participation_token: visitor.participation_token }.to_not change { visitor.reload.participation_token }
      expect(response.status).to eq 403
    end

    it 'does not allow other visitors to update a visitor' do
      expect { post :update, id: visitor.id, visitor: new_visitor_params, participation_token: "asdasdas" }.to_not change { visitor.reload.participation_token }
      expect(response.status).to eq 403
    end
  end
end
