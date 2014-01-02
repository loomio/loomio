class EmailProcessor
  def self.process(email)
    if reply_token = ReplyToken.find_by_token( find_token(email) )
      # maybe check email.from == reply_token.user.email
      message = find_message(email)

      case reply_token.replyable_type
      when "Comment"
        build_comment(body: message,
                discussion: reply_token.replyable.discussion,
                      user: reply_token.user )
        DiscussionService.add_comment(@comment)
      end
    end
  end


  def self.find_token(email)
    email_address = email.to.first[:email]
    email_address.split("@").first.
                  split("+").last
  end

  def self.find_message(email)
    raw_text = email.raw_text
    raw_text.split("\n").
      take_while { |t| t !~ /^On\s.+wrote:\s*$/ }.
      take_while { |t| t !~ /^From:\s/ }.
      take_while { |t| t != "--" }.
      take_while { |t| t != "-- " }.
      take_while { |t| t !~ /---Original Message---/ }.
      take_while { |t| t !~ /^_{30,}$/ }.
      take_while { |t| t !~ /^Sent\sfrom\smy\s.+$/ }.
      join("\n").strip
  end

  def self.build_comment(body: nil, discussion: nil, user: nil )
    @comment = Comment.new(body: body, uses_markdown: user.uses_markdown)
    @comment.discussion = discussion
    @comment.author = user
    @comment
  end
end


