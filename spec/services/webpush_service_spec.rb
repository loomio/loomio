require 'rails_helper'

describe WebpushService do
  it 'initializes vapid cert' do
    expect(WebpushService.vapid_cert.nil?).to eq false
  end

  it 'hands over push notifies to third party library' do
    @user = create(:user)
    @group = create(:group)
    @membership = create(:membership, user: @user, group: @group)
    @event = Events::MembershipRequestApproved.create(kind: 'membership_request_approved', user: @user, eventable: @membership)
    @subscription = WebpushSubscription.create(user_id: @user.id, endpoint: '', p256dh: '', auth: '')

    expect(WebPush).to receive(:payload_send)
    WebpushService.push_event(@user.id, @event.id)
  end

end
