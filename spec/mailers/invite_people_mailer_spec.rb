require "spec_helper"

describe InvitePeopleMailer do
  describe "to_join_group" do
    let(:mail) { InvitePeopleMailer.to_join_group }

    it "renders the headers" do
      mail.subject.should eq("To join group")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
