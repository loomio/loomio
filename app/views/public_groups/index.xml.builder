atom_feed do |feed|
  feed.title 'Discover Groups on Loomio'
  feed.updated(@groups.min_by(&:created_at).created_at) if @groups.any?
	
  @groups.each do |group|
  feed.entry(group) do |entry|
  	entry.title(group.name)
  	  entry.content(group.description, type: :text)
	  entry.author do |author|
	    author.name group.contact_person.name
	  end
    end
  end
end
