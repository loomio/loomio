class EmailProcessor

  def self.process(*args)
    new(*args).process
  end

  def initialize(email)
    @email = with_replaced_text(email) || email
  end

  def process
    CommentService.create(comment: comment, actor: actor)
  rescue CanCan::AccessDenied
    # No-op
  end

  private

  def email_params
    @email_params ||= EmailParams.new(@email)
  end

  def comment
    @comment ||= Comment.new(
      discussion_id: email_params.discussion_id,
      parent_id:     email_params.parent_id,
      body:          email_params.body
    )
  end

  def actor
    @author ||= User.find_by(
      id:            email_params.user_id,
      email_api_key: email_params.email_api_key
    ) || LoggedOutUser.new
  end

  def with_replaced_text(email)
    return unless email.raw_text && email.raw_html
    text = Premailer.new(email.raw_html, line_length: 10000, with_html_string: true).to_plain_text
    Griddler::Email.new(email.send(:params).merge(text: text))
  end
end
