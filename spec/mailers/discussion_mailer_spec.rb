require "spec_helper"

describe DiscussionMailer do
  let(:discussion) { create(:discussion) }
  let(:group) { discussion.group }
  let(:user) { create(:user) }

  context 'sending individual email upon new discussion creation' do
    before(:all) do
      @email = DiscussionMailer.new_discussion_created(discussion, discussion.author)
    end

    it 'renders the subject' do
      @email.subject.should == "[Loomio: #{group.full_name}] New discussion - #{discussion.title}"
    end

    it 'renders the sender email' do
      @email.from.should == ['noreply@loom.io']
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

  context "notifications disabled" do
    it "sends message to number of users subscribed to all notifications" do
      user.receive_emails = false
      group.add_member! user
      user.group_noise_level(group, 0)

      DiscussionMailer.should_not_receive(:new_discussion_created)
    end

  end

  context "sending all emails upon new discussion creation" do
    it "sends message to each group user" do
      user =  create(:user)
      group.add_member! user
      user.group_noise_level(group, 2)

      num_noise_levels = { 0 => 0, 1 => 0, 2 => 0}
      group.users.each do |group_user|
        num_noise_levels[group_user.get_group_noise_level(group)] += 1
      end

      DiscussionMailer.should_receive(:new_discussion_created).
        exactly(num_noise_levels[2]).times.and_return(stub(deliver: true))
      DiscussionMailer.spam_new_discussion_created(discussion)
    end
  end

end
