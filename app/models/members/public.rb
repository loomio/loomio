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

  def logo_url
    :earth
  end

  def logo_type
    :icon
  end
end
