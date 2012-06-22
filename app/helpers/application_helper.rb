module ApplicationHelper
  def twitterized_type(type)
    case type
      when :alert
        "warning"
      when :error
        "error"
      when :notice
        "info"
      when :success
        "success"
      else
        type.to_s
    end
  end

  def display_title(notification_size)
    result = ""
    result += "(#{notification_size}) " if notification_size > 0
    result += "Loomio"
  end
end
