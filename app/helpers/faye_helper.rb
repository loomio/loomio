module FayeHelper
  def channel_regexes
    [/discussion-(\w+)/, /notifications/]
  end

  def valid_channel?(channel)
    channel_regexes.any? do |regex|
      regex.match(channel)
    end
  end
end
