class Queries::UnvotedMotions
  def self.for(user, group)
    group.motions.
    joins("LEFT OUTER JOIN votes ON votes.motion_id = motions.id AND votes.user_id = #{user.id}").
    where('votes.id IS NULL AND motions.closed_at IS NULL')
  end
end
