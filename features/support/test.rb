require 'capybara/poltergeist'


# In test blocks
#
# To launch chrome with remote debugging:
# page.driver.debug
#
# To render a printscreen of the page:
# page.driver.render('./screenshots/file.png', :full => true)

polterops = {
	:js_errors => true, 
	:inspector => true,
	:debug => false
}

gui_switch = false

unless gui_switch
  Capybara.default_driver = :poltergeist
  Capybara.javascript_driver = :poltergeist
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, polterops)
  end
end