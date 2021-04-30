require "rails_helper"

describe UserMailer do
  shared_examples_for 'email_meta' do
    it 'renders the receiver email' do
      expect(@mail.to).to eq [@user.email]
    end

    it 'renders the sender email' do
      expect(@mail.from).to include BaseMailer::NOTIFICATIONS_EMAIL_ADDRESS
    end
  end

  context 'sending email on membership approval' do
    before :each do
      @user = create(:user)
      @group = create(:group)
      @membership = create(:membership, user: @user, group: @group)
      @event = Events::MembershipRequestApproved.create(kind: 'membership_request_approved', user: @user, eventable: @membership)
      @mail = UserMailer.membership_request_approved(@user.id, @event.id)
    end

    it_behaves_like 'email_meta'

    it 'assigns correct reply_to' do
      expect(@mail.reply_to).to eq [@group.admin_email]
    end

    it 'renders the subject' do
      expect(@mail.subject).to eq "Your request to join #{@group.full_name} has been approved"
    end

    it 'assigns confirmation_url for email body' do
      @mail.body.encoded.should match(@group.handle)
    end

  end

  context 'sending email on being added to group' do
    before :each do
      @user = create(:user)
      @inviter = create(:user)
      @group = create(:group, full_name: "Group full name")
      @membership = create(:membership, user: @user, group: @group, inviter: @inviter)
      @event = Events::UserAddedToGroup.create(kind: 'user_added_to_group', user: @inviter, eventable: @membership)
      @mail = UserMailer.user_added_to_group(@user.id, @event.id)
    end

    it 'renders the subject' do
      expect(@mail.subject).to eq "#{@inviter.name} has added you to #{@group.full_name} on #{AppConfig.theme[:site_name]}"
    end

    it 'uses group.full_name in the email body' do
      expect(@mail.body.encoded).to  include @group.full_name
    end
  end

  describe 'contact request' do
    let(:user) { create :user }
    let(:sender) { create :user }
    let(:group) { create :group }
    let(:request) { ContactRequest.new(sender: sender, recipient_id: user.id, message: "Here's a message") }
    subject { UserMailer.contact_request(contact_request: request).deliver_now }

    it 'sends a contact request' do
      expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
      last_email = ActionMailer::Base.deliveries.last
      expect(last_email.to).to include user.email
      expect(last_email.reply_to).to include sender.email
    end
  end

  describe 'catch_up' do
    let(:user) { create :user, email_catch_up_day: 7 }
    subject { UserMailer.catch_up(user.id).deliver_now }
    let(:discussion) { build :discussion, group: group }
    let(:invite_only_discussion) { build :discussion, group: nil }
    let(:poll) { build :poll, discussion: discussion }
    let(:comment) { build :comment, discussion: discussion }
    let(:group) { create :group }
    before { group.add_member! user }

    let(:some_content) do
      group.add_member! discussion.author
      group.add_member! comment.author
      invite_only_discussion.save!
      invite_only_discussion.add_guest! user, invite_only_discussion.author
      DiscussionService.create(discussion: invite_only_discussion, actor: discussion.author)
      DiscussionService.create(discussion: discussion, actor: discussion.author)
      PollService.create(poll: poll, actor: discussion.author)
      CommentService.create(comment: comment, actor: comment.author)
    end

    it 'sends a missed yesterday email' do
      some_content
      expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'does not send a missed yesterday email when there is no unread content' do
      expect { subject }.to_not change { ActionMailer::Base.deliveries.count }
    end

    it 'does not send a missed yesterday email if I have unsubscribed' do
      user.update(email_catch_up_day: nil)
      travel_to Time.now.in_time_zone(user.time_zone).next_occurring(:monday).change(hour: 6) do
        some_content
        expect { SendDailyCatchUpEmailWorker.new.perform }.to_not change { ActionMailer::Base.deliveries.count }
      end
    end

    it 'emails daily when 7' do
      user.update(email_catch_up_day: 7)
      travel_to Time.now.in_time_zone(user.time_zone).next_occurring(:monday).change(hour: 6) do
        some_content
        expect { SendDailyCatchUpEmailWorker.new.perform }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    it 'emails mondays when monday at 6am' do
      user.update(email_catch_up_day: 1)
      travel_to Time.now.in_time_zone(user.time_zone).next_occurring(:monday).change(hour: 6) do
        some_content
        expect { SendDailyCatchUpEmailWorker.new.perform }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    it 'does not email mondays when monday at 5am' do
      user.update(email_catch_up_day: 1)
      travel_to Time.now.in_time_zone(user.time_zone).next_occurring(:monday).change(hour: 5) do
        some_content
        expect { SendDailyCatchUpEmailWorker.new.perform }.to_not change { ActionMailer::Base.deliveries.count }
      end
    end

    it 'does not emails mondays when tuesday' do
      user.update(email_catch_up_day: 1)
      travel_to  Time.now.in_time_zone(user.time_zone).next_occurring(:tuesday).change(hour: 6)  do
        some_content
        expect { SendDailyCatchUpEmailWorker.new.perform }.to_not change { ActionMailer::Base.deliveries.count }
      end
    end
  end
end
