# Copyright (c) 2010, Nathaniel Ritmeyer. All rights reserved.
#
# http://www.natontesting.com
#
# Save this in a file called 'unused.rb' in your 'features/support' directory. Then, to list
# all the unused steps in your project, run the following command:
#
#   cucumber -d -f Cucumber::Formatter::Unused
#
# or...
#
#   cucumber -d -f Unused
 
require 'cucumber/formatter/stepdefs'
 
class Unused < Cucumber::Formatter::Stepdefs
  def print_summary(features)
    add_unused_stepdefs
    keys = @stepdef_to_match.keys.sort {|a,b| a.regexp_source <=> b.regexp_source}
    puts "The following steps are unused...\n---------"
    keys.each do |stepdef_key|
      if @stepdef_to_match[stepdef_key].none?
        puts "#{stepdef_key.regexp_source}\n#{stepdef_key.file_colon_line}\n---"
      end
    end
  end
end
