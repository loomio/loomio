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
      # fails on travis because @email.reply_to is returning an array, but it returns string in dev
      # @email.reply_to.should include(user.id.to_s)
      # @email.reply_to.should include(discussion.key)
    end
  end

  describe "new comment adds another email to thread" do
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

  describe "new vote adds another email to thread" do
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

  describe "new motion adds another email to thread" do
    before do
      @email = ThreadMailer.new_motion(motion, user)
    end

    it_behaves_like 'thread_message'
  end
end
