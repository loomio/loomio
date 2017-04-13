class Facebook::BaseSerializer < ActiveModel::Serializer
  include PrettyUrlHelper
  attributes :link

  def link
    polymorphic_url(object.eventable, default_url_options.merge(link_options))
  end

  private

  def link_options
    {}
  end
end
