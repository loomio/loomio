class Queries::GroupStats
  def self.visits_count(group_id)
    @visits_count ||= GroupVisit.where(group_id: group_id).count
  end

  def self.comments_count(group_ids)
    @comments_count ||= Discussion.where(group_id: group_ids).sum { |d| d.comments.count }
  end

  def self.discussions_count(group_ids)
    @discussions_count ||= Discussion.where(group_id: group_ids).count
  end

  def self.polls_count(group_ids)
    @polls_count ||= Poll.where(group_id: group_ids).count
  end

  def self.stances_count(group_ids)
    @stances_count ||= Poll.where(group_id: group_ids).sum(:stances_count)
  end

  def self.org_visits_count(group)
    @org_visits_count ||= OrganisationVisit.where(organisation_id: group.id).count
  end

  def self.poll_types_count(group_ids)
    @poll_types_count ||= Poll.where(group_id: group_ids).group(:poll_type).count
  end
end
