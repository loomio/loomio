task :git_cleanup do
  exclude_branches = ["production","staging"]
	shell=`git branch --no-color 2> /dev/null`
	regexed = shell[/^\* (.*)/,1]
	
	if regexed != "master"
		puts "You are not on the master branch."
		puts "Please switch to master branch and try again."
		next
	else
		puts "You are on the master branch, continuing."
	end

	`git remote prune origin`

	remote_branches=`git branch -r --merged`
  if(!remote_branches.nil?)
    #.*production$|.*staging$
	  remote_branches.gsub!(/.*master.*$\n#{exclude_branches.reduce("") do |result,e| result+"|.*"+e+".*$\\n" end}/,"")
	  remote_branches = remote_branches.each_line.reduce("") do |result,b|
      result +  (b.include?("origin")?b+"\n":"")
    end

	  puts "Remote merged branches to be removed:"
	  puts remote_branches == "" ? "None" : remote_branches
  end
	
	local_branches = `git branch --merged`
  if(!local_branches.nil?)
	  local_branches.gsub!(/.*master$|.*production$|.*staging$/,"") 
    if(!local_branches.nil?)
      local_branches.gsub!(/^$\n/,'')
      local_branches.gsub!(/\* /,"")
	    puts "Local merged branches to be removed:"
	    puts local_branches == "" ? "None" : local_branches
	    puts
    end
  end

	puts "Staging and production branch will not be removed"
	puts "Continue? (y/n)"
	
	continue = $stdin.gets.strip
	if continue != "y"
		puts "Exiting without removing branches"
		next
	end

  if(!remote_branches.nil?)
    remove_command = remote_branches.each_line.reduce("") do |result,l|
      result + " " + l
    end
    if(!remove_command.strip.empty?)
    	puts "git push origin " + remove_command
	    #`git push origin #{remove_command}`
    end
  end

  if(!local_branches.nil?)
    if(!local_branches.strip.empty?)
	    local_branches.each_line do |branch|
		    puts "deleting local branch "+ branch
		    branch.gsub!(/origin\//,":")
		    puts "git branch -d "+branch
		    #`git branch -d #{branch}`
	    end
    end
  end

	puts "Done!"
end
