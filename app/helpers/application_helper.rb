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

  def total_activity_count(user)
    total = 0;
    user.groups.each do |group|
      total += group.total_activity(user)
    end
    total
  end
end


