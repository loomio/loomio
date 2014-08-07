require "rails_helper"

describe ThreadMailer do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:discussion) { create :discussion, group: group }
  let(:comment) { create :comment, discussion: discussion }
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

  describe "sending email on new comment creation" do
    before do
      @email = ThreadMailer.new_comment(comment, user)
    end

    it 'renders the thread subject' do
      expect(@email.subject).to eq(discussion.title)
    end

    it 'comes from the comment author' do
      expect(@email.from).to eq(["notifications@loomio.org"])
    end

    it 'has the comment text in the body' do
      expect(@email.body.encoded).to match(comment.body)
    end

    it 'includes the thread_mailer footer' do
      expect(@email.body.encoded).to match("view it on Loomio")
    end

    it 'sets the reply_to so replies attach to the end of the thread' do
      expect(@email.reply_to).to match(user.id.to_s)
      expect(@email.reply_to).to match(discussion.key)
    end

    it 'includes any attachments as links' do
      # TODO - also should do this for comments in Yesterday on Loomio
    end
  end
end
