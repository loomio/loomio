# Counts the records that best communicate the scale of a group export. Counts
# include the complete group tree and discarded content because those records
# remain part of the pending deletion and export.
module GroupUsageSummary
  def self.for(group)
    group_ids = group.id_and_subgroup_ids
    topic_ids = Topic.where(group_id: group_ids).select(:id)

    {
      subgroups: group_ids.size - 1,
      members: Membership.active.accepted.where(group_id: group_ids).distinct.count(:user_id),
      discussions: Discussion.where(topic_id: topic_ids).count,
      polls: Poll.where(topic_id: topic_ids).count,
      comments: TopicItem.where(topic_id: topic_ids, itemable_type: "Comment").distinct.count(:itemable_id)
    }
  end
end
