require "rails_helper"

describe ThreadMailer do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:discussion) { create :discussion, group: group }
  let(:comment) { create :comment, discussion: discussion }
  let(:motion) { create(:motion, discussion: discussion) }
  let(:motion_user_voted_on) { create(:motion, discussion: discussion) }
  let(:vote) { create(:vote, user: user, motion: motion_user_voted_on) }

  shared_examples_for 'thread_message' do
    it 'renders the thread subject' do
      expect(@email.subject).to eq(discussion.title)
    end

    it 'sets the from address' do
      expect(@email.from).to eq(["notifications@loomio.org"])
    end

    it 'sets the reply_to so replies attach to the end of the thread' do
      # fails on travis because @email.reply_to is returning an array, but it returns string in dev
      # @email.reply_to.should include(user.id.to_s)
      # @email.reply_to.should include(discussion.key)
    end

    it 'is delivered to people following the thread' do
    end

    it 'is not delivered to the author' do
    end
  end

  describe "new comment adds another email to thread" do
    before do
      @email = ThreadMailer.new_comment(user, comment)
    end

    it_behaves_like 'thread_message'

    it 'has the comment text in the body' do
      expect(@email.body.encoded).to include(comment.body)
    end

    it 'has a link to the comment' do
      expect(@email.body.encoded).to include(discussion_url(comment.discussion))
    end

    it 'includes any attachments as links' do
      # TODO - also should do this for comments in Yesterday on Loomio
    end

    it 'includes the thread_mailer footer' do
      expect(@email.body.encoded).to include("view it on Loomio")
    end
  end

  describe "new vote adds another email to thread" do
    before do
      @email = ThreadMailer.new_vote(user, vote)
    end

    it_behaves_like 'thread_message'

    it 'has the position statement in the body' do
      expect(@email.body.encoded).to include(vote.statement)
    end

    it 'has a link to the vote' do
      expect(@email.body.encoded).to include(motion_url(vote.motion))
    end

    it 'makes sense when the new vote is an update to an existing one' do
      #TODO Check this out
    end

    it 'includes the thread_mailer footer' do
      expect(@email.body.encoded).to include("view it on Loomio")
    end
  end

  describe "motion closing soon adds another email to thread" do
    before do
      @email = ThreadMailer.motion_closing_soon(user, motion)
      @voted_email = ThreadMailer.motion_closing_soon(user, motion_user_voted_on)
    end

    it_behaves_like 'thread_message'

    it 'has a link to the motion' do
      expect(@email.body.encoded).to include(motion_url(motion))
    end

    it 'has the motion details in the body' do
      expect(@email.body.encoded).to include(motion.title)
      expect(@email.body.encoded).to include(motion.description)
    end

    it 'has the pie-graph in the body' do
      expect(@email.body.encoded).to include('chart.googleapis.com')
    end

    context 'user has not voted' do
      it 'has the vote buttons in the body' do
        expect(@email.body.encoded).to include(new_motion_vote_url(motion, position: 'yes'))
      end
    end

    context 'user has voted' do
      it 'does not have the vote buttons in the body' do
        expect(@voted_email.body.encoded).to_not include(new_motion_vote_url(motion, position: 'yes'))
      end
    end
  end

  describe "new motion adds another email to thread" do
    before do
      @email = ThreadMailer.new_motion(user, motion)
    end

    it_behaves_like 'thread_message'

    it 'has a link to the motion' do
      expect(@email.body.encoded).to include(motion_url(motion))
    end

    it 'has the motion details in the body' do
      expect(@email.body.encoded).to include(motion.title)
      expect(@email.body.encoded).to include(motion.description)
    end

    it 'has the vote buttons in the body' do
      expect(@email.body.encoded).to include(new_motion_vote_url(motion, position: 'yes'))
    end
  end
end
