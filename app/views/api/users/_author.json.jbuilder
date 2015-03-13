json.(author, :id, :name, :avatar_initials, :avatar_kind)
json.avatar_url author.avatar_url(:medium_large)
