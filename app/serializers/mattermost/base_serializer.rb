class Mattermost::BaseSerializer < ActiveModel::Serializer
  include PrettyUrlHelper
  include PollEmailHelper

  attributes :text

  def text
    I18n.t(:"mattermost.#{object.kind}", text_options)
  end

  private

  def text_options
    {
      actor: user.name,
      title: object.eventable.title,
      url: polymorphic_url(object.eventable, default_url_options)
    }
  end

  def user
    anonymous_or_actor_for(object)
  end
end
