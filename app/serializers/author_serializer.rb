class AuthorSerializer < ApplicationSerializer
  attributes :id, :name, :email, :username, :avatar_initials, :avatar_kind,
             :thumb_url, :time_zone, :locale, :created_at, :titles,
             :placeholder_name, :email_verified, :bot

  def include_email?
    scope[:current_user_id] == object.id || scope[:include_email]
  end

  def titles
    object.experiences['titles'] || {}
  end

  def avatar_kind
    if !object.email_verified && !object.name
      'mdi-email-outline'
    else
      object.avatar_kind
    end
  end

  def placeholder_name
    I18n.t("user.placeholder_name", hostname: object.email.to_s.split('@').last, locale: object.locale)
  end

  def include_placeholder_name?
    object.name.nil?
  end

  private

  def scope
    super || {}
  end
end
