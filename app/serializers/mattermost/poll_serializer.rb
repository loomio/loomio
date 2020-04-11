class Mattermost::PollSerializer < Mattermost::BaseSerializer
  private

  def text_options
    super.merge(poll_type: I18n.t("poll_types.#{object.eventable.poll_type}"))
  end
end
