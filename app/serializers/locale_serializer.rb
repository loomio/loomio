class LocaleSerializer < ActiveModel::Serializer
  attributes :key, :name

  def key
    object
  end

  def name
    I18n.with_locale(:en) { I18n.t(object, scope: :native_language_name) }
  end
end
