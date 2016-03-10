class EmailProcessor

  # @return [void]
  def self.process(*args)
    new(*args).process
  end

  def initialize(email)
    @email = replace_text_body(email)
  end


  def process
    email_params = EmailParams.new(@email)

    post_comment = PostComment.new(user_id: email_params.user_id,
                                   email_api_key: email_params.email_api_key,
                                   comment_params: {discussion_id: email_params.discussion_id,
                                                    body: email_params.body})
    post_comment.now!
  end

  def replace_text_body(email)
    # If there's only a text/plain body then there's nothing we can do about
    # the newlines added by email clients.
    if email.raw_text && email.raw_html
      premailer = Premailer.new email.raw_html,
                                line_length: 10000,
                                with_html_string: true
 
      Griddler::Email.new \
        email.send(:params).merge(text: premailer.to_plain_text)
    else
      email
    end
  end
end
