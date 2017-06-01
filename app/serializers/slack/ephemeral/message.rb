module Slack::Ephemeral::Message
  extend ActiveSupport::Concern
  included { attributes :response_type, :replace_original }

  def response_type
    :ephemeral
  end

  def replace_original
    false
  end

  private

  def include_channel?
    false
  end

  def include_attachments?
    false
  end
end
