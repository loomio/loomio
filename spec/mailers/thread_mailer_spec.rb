require "rails_helper"

describe ThreadMailer do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:discussion) { create :discussion, group: group }
  let(:comment) { create :comment, discussion: discussion }
  let(:motion) { create(:motion, discussion: discussion) }
  let(:vote) { create(:vote, motion: motion) }

  shared_examples_for 'thread_message' do
    it 'renders the thread subject' do
      expect(@email.subject).to eq(discussion.title)
    end

    it 'sets the reply_to so replies attach to the end of the thread' do
      expect(@email.reply_to).to include(user.id.to_s)
      expect(@email.reply_to).to include(discussion.key)
    end
  end

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

    it_behaves_like 'thread_message'

    it 'comes from the comment author' do
      expect(@email.from).to eq(["notifications@loomio.org"])
    end

    it 'has the comment text in the body' do
      expect(@email.body.encoded).to include(comment.body)
    end

    it 'includes the thread_mailer footer' do
      expect(@email.body.encoded).to include("view it on Loomio")
    end

    it 'includes any attachments as links' do
      # TODO - also should do this for comments in Yesterday on Loomio
    end
  end

  describe "sending email on new vote creation" do
    before do
      @email = ThreadMailer.new_vote(vote, user)
    end

    it_behaves_like 'thread_message'

    it 'comes from the vote author' do
      expect(@email.from).to eq(["notifications@loomio.org"])
    end

    it 'has the position statement in the body' do
      expect(@email.body.encoded).to include(vote.statement)
    end

    it 'makes sense when the new vote is an update to an existing one' do
    end
  end
end
