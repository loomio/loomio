class PollOptionSerializer < ApplicationSerializer
  attributes :id, :poll_id, :name, :priority, :color, :icon, :meaning, :prompt, :threshold_pct
end
