require 'rails_helper'

describe "Splitting replies from the original message on incoming emails" do
  it "splits the email on 'in reply to (Loomio) address colon'" do
    input_body = "Hi I'm the bit you want
    On someday (Loomio) #{BaseMailer::NOTIFICATIONS_EMAIL_ADDRESS} said:
    This is the bit that you don't want"
    output_body = ReceivedEmailService.extract_reply_body(input_body)
    expect(output_body).to eq "Hi I'm the bit you want"
  end

  it "splits the email on 'in reply to (Loomio) address colon'" do
    input_body = "Hi I'm the bit you want
    On someday (Loomio) bobo@notloomio.org wrote:
    This is the bit that you don't want"
    output_body = ReceivedEmailService.extract_reply_body(input_body)
    expect(output_body).to eq "Hi I'm the bit you want"
  end

  it "splits the email on the hidden chars" do
    input_body = "Hi I'm the bit you want
    #{EventMailer::REPLY_DELIMITER}
    This is the bit that you don't want"
    output_body = ReceivedEmailService.extract_reply_body(input_body)
    expect(output_body).to eq "Hi I'm the bit you want"
  end

  it "splits the email on signature" do
    input_body = "Hi I'm the bit you want
    --
    This is the bit that you don't want"
    output_body = ReceivedEmailService.extract_reply_body(input_body)
    expect(output_body).to eq "Hi I'm the bit you want"
  end

  it "splits the email signature without a line break" do
    author_name = "Charles Barclay"
    input_body = "Hi I'm the bit you want

    Charles Barclay
    CEO
    Some company
    +35 223333333
    \"Massive email signatures mean youre very professional\"
    "
    output_body = ReceivedEmailService.extract_reply_body(input_body, author_name)
    expect(output_body).to eq "Hi I'm the bit you want"
  end
end
