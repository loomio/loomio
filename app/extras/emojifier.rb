class Emojifier
  extend JSRuntime

  def self.emojify!(text)
    root_url = Rails.application.config.action_mailer.asset_host
    eval "(emojione.imagePathPNG = \"#{root_url}\" + emojione.imagePathPNG) &&
          (emojione.shortnameToImage(\"?\"))", text
  end

  def self.emojify_src!(text)
    emojify!(text).match(/src=\"(.*)\"/)&.send(:[], 1)
  end
end
