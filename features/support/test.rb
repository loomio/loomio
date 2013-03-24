# In test blocks
#
# To launch chrome with remote debugging:
# page.driver.debug
#
# To render a printscreen of the page:
# page.driver.render('./screenshots/file.png', :full => true)

unless ENV['FULL_BROWSER']
  require 'capybara/poltergeist'
  polter_options = {
    :js_errors => true,
    :inspector => true,
    :debug => false
  }
  Capybara.default_driver = :poltergeist
  Capybara.javascript_driver = :poltergeist
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, polter_options)
  end

  # Capybara.default_driver = :rack_test
end