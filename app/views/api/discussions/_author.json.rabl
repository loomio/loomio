attributes :id, :name, :avatar_initials, :avatar_kind

node :avatar_url do |user|
  user.avatar_url('med-large')
end
