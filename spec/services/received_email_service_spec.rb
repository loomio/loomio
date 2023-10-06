require 'rails_helper'

describe ReceivedEmailService do
  describe "Splitting replies" do
    it "splits joshuas reply" do
      input_body = "Yep, I’m happy for folks to jump in this week\nJ\n\nOn Tue, 7 Mar 2023 at 3:51 PM, jon g (via Loomio) <notifications@loomio.com> wrote:\n\n﻿﻿﻿﻿﻿﻿﻿﻿\n\nJG\n\n-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\njohn gieryn replied to you in: Are you in for season 1? ( https://www.loomio.com/d/1jq/comment/288?discussion_reader_token=Smeb&utm_campaign=user_mentioned&utm_medium=email )\n-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n\n@Ja Vi it sounds like I could get back to you (on \"are you in…\") in a day or two per your post in the other thread? 🙏\n\n—\n\nReply to this email directly or view it on Loomio ( https://www.loomio.com/d/1ajq/comment/28?discussion_reader_token=Smsweb&utm_campaign=user_mentioned&utm_medium=email ).\n\nLogo"
      output_body = ReceivedEmailService.extract_reply_body(input_body)
      expect(output_body).to eq "Yep, I’m happy for folks to jump in this week\nJ"
    end

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

  describe 'strip subject' do
    it 'correctly strips re and fwd from subject lines' do
      [
        "Re: repairing the is fwd software",
        "Fwd: repairing the is fwd software",
        "RE: FW: repairing the is fwd software",
        "FW: RE: RE: repairing the is fwd software",
        " FW repairing the is fwd software",
        "RE repairing the is fwd software",
        "RE FWD: repairing the is fwd software",
        "RE: FW repairing the is fwd software",
      ].each do |line|
        expect(line.gsub(/^( *(re|fwd?)(:| ) *)+/i, '')).to eq "repairing the is fwd software"
      end
    end
  end
end

