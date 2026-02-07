# frozen_string_literal: true

class Views::EmailComponents::Common::Avatar < Views::Base
  include Phlex::Rails::Helpers::ImageTag

  def initialize(user:, size: 36)
    @user = user
    @size = size
  end

  def view_template
    initials = @user.presence ? @user.avatar_initials : "\u{1F464}"
    if @user.presence && @user.thumb_url
      img(
        src: @user.thumb_url,
        alt: initials,
        class: "base-mailer__avatar-image rounded-circle",
        style: "width: #{@size}px; height: #{@size}px",
        width: @size,
        height: @size
      )
    else
      img(
        src: @user.avatar_initials_url(64),
        alt: initials,
        class: "base-mailer__avatar-image rounded-circle",
        style: "width: #{@size}px; height: #{@size}px",
        width: @size,
        height: @size
      )
    end
  end
end
