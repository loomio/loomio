require "rails_helper"

describe InvitePeopleMailer do

  describe '#to_join_group' do
    let(:invitation) { create :invitation, invitable: create(:group) }
    it 'inlines css' do
      mail = InvitePeopleMailer.to_join_group(invitation: invitation, locale: :en)
      expect(mail.deliver_now.encoded).to match /max-width: 600px;/
    end
  end

end
