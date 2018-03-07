class Members::Public < Members::Base
  def key
    :public
  end

  def priority
    3
  end

  def title
    I18n.t(:"notified.public_title")
  end

  def subtitle
    I18n.t(:"notified.public_#{model.class.to_s.downcase}_subtitle")
  end

  def logo_url
    :earth
  end

  def logo_type
    :icon
  end
end
