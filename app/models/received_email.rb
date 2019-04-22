class ReceivedEmail
  include ActiveModel::Model
  attr_accessor :params

  def self.fromJSON(mailinMsg)
    new(params: if mailinMsg.is_a?(String)
      JSON.parse(mailinMsg)
    else
      mailinMsg
    end)
  end

  def sender_address
    params.dig('from', 0, 'address')
  end

  def sender
    if params.dig('from', 0, 'name').present?
      "#{params.dig('from', 0, 'name')} <#{params.dig('from', 0, 'address')}>"
    else
      params.dig('from', 0, 'address')
    end
  end

  def receiving_address
    params.dig('to')&.find{|contact| contact['address'].ends_with?(ENV['REPLY_HOSTNAME'])}&.dig('address')
  end

  def receiving_address_local_part
    receiving_address.split('@').first
  end

  def headers
    params['headers']
  end

  def subject
    params['subject']
  end

  def body
    extract_reply_body(body_as_text)
  end

  def body_format
    'md'
  end

  def locale
    params['language']
  end

  def valid?
    receiving_address.present?
  end

  def mentioned_email_addresses
    body.scan(AppConfig::EMAIL_REGEX).uniq.reject { |email| email == self.sender_address.scan(AppConfig::EMAIL_REGEX) }
  end

  def receiving_address
    params['to'].find{|contact| contact['address'].ends_with?(ENV['REPLY_HOSTNAME'])}['address']
  end

  #  these methods below were extracted from Griddler. Thank you.
  private

  def body_as_text
    if params['html'].present?
     Premailer.new(params['html'], line_length: 10000, with_html_string: true).to_plain_text
   else
     params['text']
   end
  end

  def extract_reply_body(body)
    if body.blank?
      ""
    else
      remove_unwanted_lines(remove_reply_portion(body))
    end
  end

  def remove_unwanted_lines(body)
    body.split(/[\r]*\n/).reject do |line|
      line =~ /^[[:space:]]+>/ ||
      line =~ /^[[:space:]]*Sent from my /
    end.join("\n").strip
  end

  def remove_reply_portion(body)
    regex_split_points.inject(body) do |result, split_point|
      result.split(split_point).first || ""
    end
  end

  def regex_split_points
    [
      /^.+\(Loomio\).+#{BaseMailer::NOTIFICATIONS_EMAIL_ADDRESS}.+:$/i,
      /#{DiscussionMailer::REPLY_DELIMITER}/,
      /^[[:space:]]*[-]+[[:space:]]*Original Message[[:space:]]*[-]+[[:space:]]*$/i,
      /^[[:space:]]*--[[:space:]]*$/,
      /^[[:space:]]*\>?[[:space:]]*On.*\r?\n?.*wrote:\r?\n?$/,
      /^On.*<\r?\n?.*>.*\r?\n?wrote:\r?\n?$/,
      /On.*wrote:/,
      /\*?From:.*$/i,
      /^[[:space:]]*\d{4}[-\/]\d{1,2}[-\/]\d{1,2}[[:space:]].*[[:space:]]<.*>?$/i,
      /(_)*\n[[:space:]]*De :.*\n[[:space:]]*Envoyé :.*\n[[:space:]]*À :.*\n[[:space:]]*Objet :.*\n$/i, # French Outlook
      /^[[:space:]]*\>?[[:space:]]*Le.*<\n?.*>.*\n?a[[:space:]]?\n?écrit :$/, # French
      /^[[:space:]]*\>?[[:space:]]*El.*<\n?.*>.*\n?escribió:$/ # Spanish
    ]
  end
end
