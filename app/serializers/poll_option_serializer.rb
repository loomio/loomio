class PollOptionSerializer < ApplicationSerializer
  attributes :name, :id, :poll_id, :priority, :score_counts, :color

  def color
    AppConfig.colors.dig(poll.poll_type, object.priority % AppConfig.colors.length)
  end
end
