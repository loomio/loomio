class Events::VersionSerializer < Events::BaseSerializer
  has_one :eventable, polymorphic: true, serializer: ::VersionSerializer
end
