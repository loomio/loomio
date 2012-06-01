require "spec_helper"

describe DiscussionMailer do
  let(:discussion) { create_discussion }
  let(:group) { discussion.group }

  context 'sending individual email upon new discussion creation' do
    before(:all) do
      @email = DiscussionMailer.new_discussion_created(discussion, discussion.author)
    end

    it 'renders the subject' do
      @email.subject.should == "[Loomio: #{group.name}] New discussion - #{discussion.title}"
    end

    it 'renders the sender email' do
      @email.from.should == ['noreply@loom.io']
    end

    it 'sends email to group members but not author' do
      @email.to.should == [discussion.author.email]
    end

    it 'assigns url_for discussion' do
      @email.body.encoded.should match(discussion_url(discussion))
    end
  end

  context "sending all emails upon new discussion creation" do
    it "sends message to each group user" do
      DiscussionMailer.should_receive(:new_discussion_created).
        exactly(group.users.count).times.and_return(stub(deliver: true))
      DiscussionMailer.spam_new_discussion_created(discussion)
    end
  end

end
