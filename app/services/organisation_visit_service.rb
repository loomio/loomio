class OrganisationVisitService
  def self.record(visit: , organisation: )
    OrganisationVisit.find_or_create_by(visit: visit, organisation: organisation) if visit
  rescue ActiveRecord::RecordNotUnique
    true # it's fine if this happens
  end
end
