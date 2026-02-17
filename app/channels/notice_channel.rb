class NoticeChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notice"
  end
end
