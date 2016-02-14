class Emojifier
  extend JSRuntime

  def self.emojify!(text)
    eval "emojione.shortnameToImage(\"?\")", text
  end
end
