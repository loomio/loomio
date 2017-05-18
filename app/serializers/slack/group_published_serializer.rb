class Slack::GroupPublishedSerializer < Slack::BaseSerializer
  def text
    I18n.t(:"slack.join_loomio_group")
  end

  def channel
    object.custom_fields['identifier']
  end

  private

  def link_options
    default_url_options
  end
end
