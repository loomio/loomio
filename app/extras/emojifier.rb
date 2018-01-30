class Emojifier
  extend JSRuntime

  def self.emojify!(text)
    eval "execjs.emojify(\"#{asset_url}\", \"?\")", text
  end

  def self.asset_url
    Rails.application.config.action_mailer.asset_host
  end

  def self.emojify_src!(text)
    emojify!(text).match(/src=\"(.*)\"/)&.send(:[], 1)
  end
end
