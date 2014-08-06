require "rails_helper"

describe ThreadMailer do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:discussion) { create :discussion, group: group }
  let(:motion) { create(:motion, discussion: discussion) }

  describe 'sending email on new motion creation' do
    before do
      @email = ThreadMailer.motion_created(motion, user)
    end

    #ensure that the subject is correct
    it 'renders the subject' do
      @email.subject.should == "#{I18n.t(:proposal)}: #{motion.name} - #{group.name}"
    end

    #ensure that the sender is correct
    it 'renders the sender email' do
      @email.from.should == ["notifications@loomio.org"]
    end

    #ensure that reply to is correct
    it 'assigns reply to' do
      @email.reply_to.should == [motion.author_email]
    end

    it 'sends email to group members but not author' do
      @email.to.should == [user.email]
    end

    #ensure that the confirmation_url appears in the email body
    it 'assigns url_for motion' do
      @email.body.encoded.should match(motion_url(motion))
    end
  end
end
