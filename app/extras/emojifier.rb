class Emojifier
  extend JSRuntime

  def self.emojify!(text)
    root_url = Rails.application.routes.url_helpers.root_url(ActionMailer::Base.default_url_options)
    eval "(emojione.imagePathPNG = \"#{root_url.chomp('/')}\" + emojione.imagePathPNG) &&
          (emojione.shortnameToImage(\"?\"))", text
  end
end
