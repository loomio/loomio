class VisitService
  def self.record(visit: , group: , user:)
    return unless visit && user.is_logged_in? && group.presence
    begin
      organisation = group.parent_or_self
      OrganisationVisit.find_or_create_by(visit: visit, organisation: organisation) do |ov|
        ov.user = user
        ov.member = organisation.members.include? user
      end

      GroupVisit.find_or_create_by(visit: visit, group: group) do |gv|
        gv.user = user
        gv.member = group.members.include? user
      end
    rescue ActiveRecord::RecordNotUnique
      retry # find or create is not threadsafe, this recovers from that problem
    end
  end
end
