require 'rails_helper'

describe "Splitting replies from the original message on incoming emails" do
  it "splits the email on 'in reply to (Loomio) address colon'" do
    input_body = "Hi I'm the bit you want,
    On someday (Loomio) #{BaseMailer::NOTIFICATIONS_EMAIL_ADDRESS} said:
    This is the bit that you don't want"
    output_body = Griddler::EmailParser.extract_reply_body(input_body)
    expect(output_body).to eq "Hi I'm the bit you want,"
  end

  it "splits the email on 'in reply to (Loomio) address colon'" do
    input_body = "Hi I'm the bit you want,
    On someday (Loomio) bobo@notloomio.org said:
    This is the bit that you don't want"
    output_body = Griddler::EmailParser.extract_reply_body(input_body)
    expect(output_body).to_not eq "Hi I'm the bit you want,"
  end

  it "splits the email on the hidden chars" do
    input_body = "Hi I'm the bit you want,
    #{ThreadMailer::REPLY_DELIMITER}
    This is the bit that you don't want"
    output_body = Griddler::EmailParser.extract_reply_body(input_body)
    expect(output_body).to eq "Hi I'm the bit you want,"
  end
end
