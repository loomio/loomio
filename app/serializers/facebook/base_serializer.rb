class Facebook::BaseSerializer < ActiveModel::Serializer
  include PrettyUrlHelper
  attributes :message, :link

  def message
    I18n.t :"webhooks.facebook.#{object.kind}", text_options
  end

  def link
    polymorphic_url(object.eventable, default_url_options.merge(link_options))
  end

  private

  def text_options
    {}
  end

  def link_options
    {}
  end
end
