require 'rails_helper'

describe API::V1::ReceivedEmailsController do
  let(:group) { create :group }
  let(:another_group) { create :group }
  let(:user) { create :user }

  before do
    sign_in user
    group.add_admin! user
  end

  describe 'index' do
    before do
      ReceivedEmail.create!(
        group_id: group.id,
        headers: {
          to: "#{group.handle}@#{ENV['REPLY_HOSTNAME']}",
          from: "someone@gmail.com",
        },
        body_html: "<p>hello there</p>",
        body_text: "hello there"
      )
    end

    describe 'correct group_id' do
      it 'returns emails' do
        get :index, params: { group_id: group.id }
        json = JSON.parse(response.body)
        expect(json['received_emails'].length).to eq 1
      end
    end

    describe 'correct group_id, not an admin' do
      it 'returns emails' do
        group.memberships.find_by(user_id: user.id).update(admin: false)
        get :index, params: { group_id: group.id }
        expect(response.status).to eq 403
      end
    end

    describe 'incorrect group_id' do
      it 'returns access denied' do
        group.memberships.find_by(user_id: user.id).update(admin: false)
        get :index, params: { group_id: another_group.id }
        expect(response.status).to eq 403
      end
    end
  end

  describe 'aliases index' do
    let!(:member_email_alias) {
      MemberEmailAlias.create!(
        email: 'test@example.com',
        group_id: group.id,
        user_id: user.id,
        author_id: user.id
      )
    }

    describe 'correct group_id' do
      it 'returns aliases' do
        get :aliases, params: { group_id: group.id }
        json = JSON.parse(response.body)
        expect(json['aliases'].length).to eq 1
      end
    end

    describe 'incorrect group_id' do
      it 'returns access denied' do
        get :aliases, params: { group_id: another_group.id }
        expect(response.status).to eq 403
      end
    end
  end

  describe 'allow and block' do
    let!(:received_email) {
      ReceivedEmail.create!(
        group_id: group.id,
        headers: {
          to: "#{group.handle}@#{ENV['REPLY_HOSTNAME']}",
          from: "someone@gmail.com",
        },
        body_html: "<p>hello there</p>",
        body_text: "hello there"
      )
    }

    let!(:another_received_email) {
      ReceivedEmail.create!(
        group_id: another_group.id,
        headers: {
          to: "#{group.handle}@#{ENV['REPLY_HOSTNAME']}",
          from: "someone@gmail.com",
        },
        body_html: "<p>hello there</p>",
        body_text: "hello there"
      )
    }

    it 'allow correct id' do
      expect { post :allow, params: { id: received_email.id, user_id: user.id } }.to change { MemberEmailAlias.count }.by(1)
      json = JSON.parse(response.body)
      expect(json['received_emails'].length).to eq 1
      expect(MemberEmailAlias.last.user_id).to eq user.id
    end

    it 'allow incorrect id' do
      expect { post :allow, params: { id: another_received_email.id, user_id: user.id } }.not_to change { MemberEmailAlias.count }
      expect(response.status).to eq 404
    end

    it 'allow trial group' do
      Subscription.for(received_email.group).update(plan: 'trial')
      expect { post :allow, params: { id: received_email.id, user_id: user.id } }.not_to change { MemberEmailAlias.count }
      expect(response.status).to eq 403
    end

    it 'block correct id' do
      expect { post :block, params: { id: received_email.id, user_id: user.id } }.to change { MemberEmailAlias.count }.by(1)
      json = JSON.parse(response.body)
      expect(json['received_emails'].length).to eq 1
      expect(MemberEmailAlias.last.user_id).to eq nil
    end

    it 'block incorrect id' do
      expect { post :block, params: { id: another_received_email.id, user_id: user.id } }.not_to change { MemberEmailAlias.count }
      expect(response.status).to eq 404
    end
  end
end
