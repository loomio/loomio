class PollOptionSerializer < ApplicationSerializer
  attributes :id, :poll_id, :name, :name_format, :priority, :color

  def name_format
    poll = cache_fetch(:poll_options_by_poll_id, object.poll_id) { object.poll }
    case poll.poll_type
    when 'proposal', 'count' then 'i18n'
    when 'meeting' then 'iso8601'
    else
      'none'
    end
  end
end
