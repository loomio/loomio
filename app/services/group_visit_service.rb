class GroupVisitService
  def self.record(visit: , group: )
    GroupVisit.find_or_create_by(visit: visit, group: group) if visit
  rescue ActiveRecord::RecordNotUnique
    true # it's fine if this happens
  end
end
