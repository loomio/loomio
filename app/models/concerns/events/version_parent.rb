module Events::VersionParent
  include Events::LookupMissingParent

  def self.lookup_parent(version)
    version.item.created_event
  end
end
