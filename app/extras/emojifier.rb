class Emojifier
  extend JSRuntime

  def self.emojify!(text)
    eval("emojione.shortnameToImage('#{text.strip}')")
  rescue => e
    Airbrake.notify e
    text
  end
end
