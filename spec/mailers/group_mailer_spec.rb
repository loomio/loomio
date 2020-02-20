require "rails_helper"

describe GroupMailer do
  describe '#membership_requested' do
    before do
      @group = create(:group)
      @admin = @group.admins.first
      @membership_request = create(:membership_request, group: @group, name: 'bob jones', email: "bobby@jones.org")
      @event = Event.create(kind: 'membership_requested', eventable: @membership_request)
      @mail = GroupMailer.membership_requested(@admin.id, @event.id)
    end

    it 'renders the subject' do
      expect(@mail.subject).to eq "#{@membership_request.name} has requested to join #{@group.full_name}"
    end

    it "sends email to group admins" do
      expect(@mail.to).to eq [@admin.email]
    end

    context "requestor is an existing loomio user" do
      it 'renders the sender email' do
        expect(@mail.from).to include BaseMailer::NOTIFICATIONS_EMAIL_ADDRESS
      end

      it 'assigns correct reply_to' do
        expect(@mail.reply_to).to eq [@membership_request.email]
      end

      it 'assigns confirmation_url for email body' do
        @mail.body.encoded.should match(/#{@group.key}/)
      end
    end

    context "requestor is not a loomio user"
  end
end
