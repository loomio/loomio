class PollOptionSerializer < ApplicationSerializer
  attributes :id, :poll_id, :name, :priority, :color, :icon, :meaning, :prompt
end
