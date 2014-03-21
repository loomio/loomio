require "spec_helper"

describe DiscussionMailer do
  let(:discussion) { create_discussion }
  let(:group) { discussion.group }

  context 'sending individual email upon new discussion creation' do
    before do
      @email = DiscussionMailer.new_discussion_created(discussion, discussion.author)
    end

    it 'renders the subject' do
      @email.subject.should == "[Loomio: #{group.full_name}] New discussion - #{discussion.title}"
    end

    it 'renders the sender email' do
      @email.from.should == ['noreply@loomio.org']
    end

    it 'sends email to group members but not author' do
      @email.to.should == [discussion.author_email]
    end

    it 'assigns url_for discussion' do
      @email.body.encoded.should match(discussion_url(discussion))
    end

    it 'assigns reply to' do
      @email.reply_to.should == [discussion.author_email]
    end
  end
end
