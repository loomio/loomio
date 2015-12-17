module MessageChannel
  extend ActiveSupport::Concern

  def message_channel
    "/#{self.class.to_s.downcase}-#{self.key}"
  end
end
