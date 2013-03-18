Then /^facebook meta-data should be present$/ do
  page.should have_xpath("//head/meta[@property=\"fb:app_id\"]")
end

Then /^social meta-data about the group should be present$/ do
  page.should have_xpath("//head/meta[ @property='og:title' ][ contains(@content,\"#{@group.name}\") ]")
  page.should have_xpath("//head/meta[ @property='og:description' ][ contains(@content,\"#{@group.description}\") ]")
end

Then /^social meta-data about the discussion should be present$/ do
  page.should have_xpath("//head/meta[ @property='og:title' ][ contains(@content,\"#{@discussion.title}\") ]")
  page.should have_xpath("//head/meta[ @property='og:description' ][ contains(@content,\"#{@discussion.description}\") ]")
end

Then /^social meta-data about the group should not be present$/ do
  page.should have_xpath("//head/meta[ @property='og:title' ]")
  page.should have_xpath("//head/meta[ @property='og:description' ]")
  page.should_not have_xpath("//head/meta[ @property='og:title' ][ contains(@content,\"#{@group.name}\") ]")
  page.should_not have_xpath("//head/meta[ @property='og:description' ][ @content='A description for this group' ]")
end

Then /^social meta-data about the discussion should not be present$/ do
  page.should have_xpath("//head/meta[ @property='og:title' ]")
  page.should have_xpath("//head/meta[ @property='og:description' ]")
  page.should_not have_xpath("//head/meta[ @property='og:title' ][ contains(@content,\"#{@discussion.title}\") ]")
  page.should_not have_xpath("//head/meta[ @property='og:description' ][ contains(@content,\"#{@discussion.description}\") ]")
end