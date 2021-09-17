class Queries::GroupStats
  def self.comments_count(group_ids)
    Discussion.where(group_id: group_ids).sum { |d| d.comments.count }
  end

  def self.discussions_count(group_ids)
    Discussion.where(group_id: group_ids).count
  end

  def self.polls_count(group_ids)
    Poll.where(group_id: group_ids).count
  end

  def self.voters_count(group_ids)
    Poll.where(group_id: group_ids).sum(:voters_count)
  end
  
  def self.poll_types_count(group_ids)
    Poll.where(group_id: group_ids).group(:poll_type).count
  end
end
