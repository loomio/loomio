Given /^the translator exists and can translate$/ do 
  Discussion.any_instance.stub(:id_field).and_return(1)
  Comment.any_instance.stub(:id_field).and_return(1)
  Comment.stub(:get_instance).and_return(@comment)
  TranslationService.stub(:available?).and_return(true)
  TranslationService.stub(:can_translate?).with(anything()).and_return(true)
  TranslationService.any_instance.stub(:translate).with(anything()).and_return({id: 1, body: 'successful translation' })
end

Given /^the translator exists and cannot translate$/ do
  Discussion.any_instance.stub(:id_field).and_return(1)
  Comment.any_instance.stub(:id_field).and_return(1)
  Comment.stub(:get_instance).and_return(@comment)
  TranslationService.stub(:available?).and_return(true)
  TranslationService.stub(:can_translate?).with(anything()).and_return(true)
  TranslationService.any_instance.stub(:translate).with(anything()).and_return({ id: 1, body: 'Unable to complete translation' })
end

When /^I click on the translate link$/ do
  click_link 'translate-comment-1'
end

Then /^I should see a link to translate the comment$/ do
  page.should have_css('#translate-comment-1')
end

Then /^I should not see a link to translate the comment$/ do
  page.should have_no_css('#translate-comment-1')
end

Then /^the translation should appear$/ do
  page.should have_content('successful translation')
end

Then /^a failure to translate message should appear$/ do
  page.should have_content('Unable to complete translation')
end