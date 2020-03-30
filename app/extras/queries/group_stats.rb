class Queries::GroupStats
  def self.visits_count(group_id)
    # GroupVisit.where(group_id: group_id).count
    Ahoy::Event.where("properties -> 'groupId' is not null and properties ->> 'groupId' = '#{group_id}'").pluck(:visit_id).uniq.count
  end

  def self.comments_count(group_ids)
    Discussion.where(group_id: group_ids).sum { |d| d.comments.count }
  end

  def self.discussions_count(group_ids)
    Discussion.where(group_id: group_ids).count
  end

  def self.polls_count(group_ids)
    Poll.where(group_id: group_ids).count
  end

  def self.stances_count(group_ids)
    Poll.where(group_id: group_ids).sum(:stances_count)
  end

  def self.org_visits_count(group)
    # OrganisationVisit.where(organisation_id: group.id).count
    Ahoy::Event.where("properties -> 'organisationId' is not null and properties ->> 'organisationId' = '#{group.id}'").pluck(:visit_id).uniq.count
  end

  def self.poll_types_count(group_ids)
    Poll.where(group_id: group_ids).group(:poll_type).count
  end
end
