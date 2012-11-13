require "spec_helper"

describe GroupInvitationMailer do
  let(:group) { double :group, :name => "Rainbows" }
  let(:inviter) { double "inviter", :email => "jon@loom.io",
                                    :name => "Jon Lemmon" }

  describe "invite_member" do
    let(:mail) { GroupInvitationMailer.invite_member(
                 :recipient_email => 'rob@guthrie.com',
                 :group => group,
                 :inviter => inviter,
                 :token => "12345") }

    it "renders the headers" do
      mail.subject.should eq("Invitation to join Loomio (#{group.name})")
      mail.to.should eq(["rob@guthrie.com"])
      mail.from.should eq(["contact@loom.io"])
      mail.reply_to.should eq(["jon@loom.io"])
    end

    it "renders the body" do
      mail.body.encoded.should =~ /#{inviter.name}/
    end
  end

  describe "invite_admin" do
    before do
      User.stub(:loomio_helper_bot => stub(:email => "contact@loom.io"))
    end
    let(:mail) { GroupInvitationMailer.invite_admin(
                 :recipient_email => 'rob@guthrie.com',
                 :group => group,
                 :token => "12345") }

    it "renders the headers" do
      mail.subject.should eq("Invitation to join Loomio (#{group.name})")
      mail.to.should eq(["rob@guthrie.com"])
      mail.from.should eq(["contact@loom.io"])
      mail.reply_to.should eq(["contact@loom.io"])
    end

    it "renders the body" do
      mail.body.encoded.should =~ /invited to Loomio/
    end
  end
end
