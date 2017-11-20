require 'rails_helper'

describe API::AnnouncementsController do
  let (:user) { create :user }
  let(:another_user) { create :user }
  let(:a_third_user) { create :user }
  let(:a_fourth_user) { create :user }
  let(:group) { create :formal_group }
  let(:group_notified) {{
    id: group.id,
    type: "Group",
    notified_ids: [another_user.id, a_third_user.id]
  }}
  let(:user_notified) {{
    id: a_fourth_user.id,
    type: "User",
    notified_ids: [a_fourth_user.id]
  }}
  let(:email_notified) {{
    id: "test@example.com",
    type: "Invitation",
    notified_ids: []
  }}

  before do
    group.add_admin! user
    group.add_member! another_user
    group.add_member! a_third_user
    sign_in user
  end

  describe 'create' do
    describe 'poll' do
      let(:poll) { create :poll, group: group }
      let(:announcement_params) {{
        announceable_type: "Poll",
        announceable_id:   poll.id
      }}
      let(:bad_announcement_params) {{
        announceable_type: "Poll",
        announceable_id:   create(:poll).id
      }}

      it 'creates an announcement to all notified types' do
        announcement_params[:notified] = [group_notified, user_notified, email_notified]
        expect { post :create, announcement: announcement_params }.to change { Announcement.count }.by(1)
        expect(response.status).to eq 200
        a = Announcement.last
        expect(a.users).to include another_user
        expect(a.users).to include a_third_user
        expect(a.users).to include a_fourth_user
        expect(a.invitations.pluck(:recipient_email)).to include email_notified[:id]
      end

      it 'announces to a group' do
        announcement_params[:notified] = [group_notified]
        expect { post :create, announcement: announcement_params }.to change { ActionMailer::Base.deliveries.count }.by(2)
        a = Announcement.last
        expect(a.users).to include another_user
        expect(a.users).to include a_third_user
        expect(a.users).to_not include a_fourth_user
        expect(a.invitations).to be_empty
      end

      it 'announces to an individual user' do
        announcement_params[:notified] = [user_notified]
        expect { post :create, announcement: announcement_params }.to change { ActionMailer::Base.deliveries.count }.by(1)
        a = Announcement.last
        expect(poll.guest_group.members).to include a_fourth_user
        expect(poll.group.members).to_not include a_fourth_user
        expect(a.users).to include a_fourth_user
        expect(a.users).to_not include another_user
        expect(a.invitations).to be_empty
      end

      it 'announces to an email address' do
        announcement_params[:notified] = [email_notified]
        expect { post :create, announcement: announcement_params }.to change { ActionMailer::Base.deliveries.count }.by(1)
        a = Announcement.last
        expect(poll.guest_group.invitations).to eq a.invitations
        expect(a.users).to be_empty
        expect(a.invitations.pluck(:recipient_email)).to eq [email_notified[:id]]
      end

      it 'does not announce the same user twice' do
        announcement_params[:notified] = [user_notified, user_notified]
        expect { post :create, announcement: announcement_params }.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(Announcement.last.users.count).to eq 1
      end

      it 'does not announce the same email twice' do
        announcement_params[:notified] = [email_notified, email_notified]
        expect { post :create, announcement: announcement_params }.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(Announcement.last.invitations.count).to eq 1
      end

      it 'does not allow announcements by unauthorized users' do
        announcement_params[:announceable_id] = create(:poll).id
        expect { post :create, announcement: announcement_params }.to_not change { ActionMailer::Base.deliveries.count }
        expect(response.status).to eq 403
      end
    end

    describe 'discussion' do
      let(:discussion) { create :discussion, group: group }
      let(:announcement_params) {{
        announceable_type: "Discussion",
        announceable_id:   discussion.id
      }}

      it 'creates an announcement to all notified types' do
        announcement_params[:notified] = [group_notified, user_notified, email_notified]
        expect { post :create, announcement: announcement_params }.to change { Announcement.count }.by(1)
        expect(response.status).to eq 200
        a = Announcement.last
        expect(a.users).to include another_user
        expect(a.users).to include a_third_user
        expect(a.users).to include a_fourth_user
        expect(a.invitations.pluck(:recipient_email)).to include email_notified[:id]
      end

      it 'announces to a group' do
        announcement_params[:notified] = [group_notified]
        expect { post :create, announcement: announcement_params }.to change { ActionMailer::Base.deliveries.count }.by(2)
        a = Announcement.last
        expect(a.users).to include another_user
        expect(a.users).to include a_third_user
        expect(a.users).to_not include a_fourth_user
        expect(a.invitations).to be_empty
      end

      it 'announces to an individual user' do
        announcement_params[:notified] = [user_notified]
        expect { post :create, announcement: announcement_params }.to change { ActionMailer::Base.deliveries.count }.by(1)
        a = Announcement.last
        expect(discussion.guest_group.members).to include a_fourth_user
        expect(discussion.group.members).to_not include a_fourth_user
        expect(a.users).to include a_fourth_user
        expect(a.users).to_not include another_user
        expect(a.invitations).to be_empty
      end

      it 'announces to an email address' do
        announcement_params[:notified] = [email_notified]
        expect { post :create, announcement: announcement_params }.to change { ActionMailer::Base.deliveries.count }.by(1)
        a = Announcement.last
        expect(discussion.guest_group.invitations).to eq a.invitations
        expect(a.users).to be_empty
        expect(a.invitations.pluck(:recipient_email)).to eq [email_notified[:id]]
      end

      it 'does not announce the same user twice' do
        announcement_params[:notified] = [user_notified, user_notified]
        expect { post :create, announcement: announcement_params }.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(Announcement.last.users.count).to eq 1
      end

      it 'does not announce the same email twice' do
        announcement_params[:notified] = [email_notified, email_notified]
        expect { post :create, announcement: announcement_params }.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(Announcement.last.invitations.count).to eq 1
      end

      it 'does not allow announcements by unauthorized users' do
        announcement_params[:announceable_id] = create(:discussion).id
        expect { post :create, announcement: announcement_params }.to_not change { ActionMailer::Base.deliveries.count }
        expect(response.status).to eq 403
      end
    end
  end
end
