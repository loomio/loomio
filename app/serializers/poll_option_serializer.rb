class PollOptionSerializer < ApplicationSerializer
  attributes :id,
             :poll_id,
             :name,
             :priority,
             :color,
             :icon,
             :meaning,
             :prompt,
             :test_operator,
             :test_percent,
             :test_against
end
