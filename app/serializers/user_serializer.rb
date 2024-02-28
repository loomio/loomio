class UserSerializer < AuthorSerializer
  attributes :short_bio,
             :short_bio_format,
             :content_locale,
             :location,
             :has_password,
             :autodetect_time_zone,
             :avatar_url,
             :attachments,
             :date_time_pref

  def include_has_password?
    scope[:include_password_status]
  end
end
