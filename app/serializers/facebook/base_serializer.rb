class Facebook::BaseSerializer < ActiveModel::Serializer
  include PrettyUrlHelper
  attributes :link, :message

  def link
    polymorphic_url(object.eventable, default_url_options.merge(link_options))
  end

  def message
    object.custom_fields['message']
  end

  private

  def include_message?
    message.present?
  end

  def community
    @community ||= Communities::Base.find(object.custom_fields['community_id'])
  end

  def link_options
    { identifier: community.identifier }
  end
end
