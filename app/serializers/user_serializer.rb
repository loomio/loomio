class UserSerializer < AuthorSerializer
  attributes :short_bio,
             :short_bio_format,
             :content_locale,
             :location,
             :has_password,
             :autodetect_time_zone,
             :avatar_url,
             :attachments,
             :date_time_pref,
             :email_delivery_blocked,
             :sign_in_count


  def include_has_password?
    scope[:include_password_status]
  end

  def include_location?
    scope[:current_user_id] == object.id
  end

  def include_sign_in_count?
    scope[:current_user_id] == object.id
  end

  def email_delivery_blocked
    if scope[:cache]
      scope[:cache].email_delivery_blocked?(object)
    else
      object.email_delivery_blocked?
    end
  end

  def include_email_delivery_blocked?
    scope[:include_email_delivery_status]
  end
end
