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
end
