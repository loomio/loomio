class MybbService
	def self.convert_text(text)
		text.gsub('[hr]', '<hr>').gsub(/\[quote="[^\]]+\]/, '<blockquote>').gsub('[/quote]', '</blockquote>')
	end

	# note, I edited the posts.json and deleted the first couple of lines and the last couple too.
	# so I could read the file line by line and just consider each line a post
	# thats why I chop the trailing commas
  def self.import(filename, group_id)
    user_ids = {}
    discussion_ids = {}
    comment_ids = {}

    posts = URI.open(filename, 'r').map do |line|
    	line.chop! if line.ends_with?("\n")
    	line.chop! if line.ends_with?(',')
    	JSON.parse(line)
    rescue
    	byebug
		end

    ActiveRecord::Base.transaction do
    	# create discussions
    	posts.sort_by {|post| post['replyto'].to_i }.each do |post|
    		# create user if not exists
    		unless user_ids[post['uid']]
    			email = "#{post['username'].parameterize.gsub('-','')}@mybb.example.com"
    			u = User.find_by(email: email) || u = User.create!(
    				name: post['username'],
    				email: email
  				)
    			user_ids[post['uid']] = u.id
    		end

    		# create discussion if not exists
    		if !discussion_ids[post['tid']]
    			d = Discussion.create!(
    				group_id: group_id, 
    				author_id: user_ids[post['uid']],
    				title: post['subject'], 
    				description: convert_text(post['message']),
    				created_at: Time.at(post['dateline'].to_i),
    				updated_at: Time.at(post['dateline'].to_i)
  				)
    			d.create_missing_created_event!
    			discussion_ids[post['tid']] = d.id
    		else
	    		if post['message'].present?
	    			parent = Comment.find_by(id: post['replyto'].to_i)
	    			comment = Comment.create!(
	    				parent_id: comment_ids[parent&.id],
	    				discussion_id: discussion_ids[post['tid']],
	    				user_id: user_ids[post['uid']],
	    				created_at: Time.at(post['dateline'].to_i),
	    				updated_at: Time.at(post['dateline'].to_i),
	    				body: convert_text(post['message'])
	  				)
	  				comment_ids[post['pid']] = comment.id
	  				Event.create!(
	  					user_id: user_ids[post['uid']],
	  					discussion_id: discussion_ids[post['tid']],
	  					kind: "new_comment",
	  					eventable: comment,
	  					created_at: Time.at(post['dateline'].to_i),
	  					updated_at: Time.at(post['dateline'].to_i)
						)
	  			end
	  		end
    	end
		end
		ids = Discussion.where(group_id: group_id).pluck(:id)
		ids.each {|id| EventService.repair_thread(id)}
		SearchIndexWorker.new.perform(ids)
	end
end