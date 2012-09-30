require "spec_helper"

describe GroupInvitationMailer do
  describe "invite_member" do
    let(:mail) { GroupInvitationMailer.invite_member }

    it "renders the headers" do
      mail.subject.should eq("Invite member")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
