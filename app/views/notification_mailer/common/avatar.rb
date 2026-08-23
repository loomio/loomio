# frozen_string_literal: true

class Views::NotificationMailer::Common::Avatar < Views::ApplicationMailer::Component

  def initialize(user:, size: 36)
    @user = user
    @size = size
  end

  def view_template
    user = @user.presence || LoggedOutUser.new
    if user.thumb_url
      avatar_url = user.thumb_url
      avatar_url = "#{root_url.chomp('/')}#{avatar_url}" if avatar_url.start_with?('/')

      img(
        src: avatar_url,
        alt: user.name,
        class: "base-mailer__avatar-image rounded-circle",
        style: "width: #{@size}px; height: #{@size}px",
        width: @size,
        height: @size
      )
    else
      img(
        src: user.avatar_initials_url(64),
        alt: user.name,
        class: "base-mailer__avatar-image rounded-circle",
        style: "width: #{@size}px; height: #{@size}px",
        width: @size,
        height: @size
      )
    end
  end
end
