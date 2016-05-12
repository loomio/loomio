class EmailProcessor

  def self.process(*args)
    new(*args).process
  end

  def initialize(email)
    @email = replace_text_body(email)
  end


  def process
    # I guess we detect locale by the word used here:
    if @email.to[0][:email] == "decide@#{ENV['REPLY_HOSTNAME']}"
      DecisionSessionService.initiate_by_email(email: @email, locale: 'en')
    else
      email_params = EmailParams.new(@email)
      user = User.find_by(id: email_params.user_id,
                          email_api_key: email_params.email_api_key)

      comment = Comment.new(discussion_id: email_params.discussion_id,
                            body: email_params.body)

      CommentService.create(comment: comment, actor: user || LoggedOutUser.new)
    end
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
