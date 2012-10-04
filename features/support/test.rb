require 'capybara/poltergeist'

polterops = {:js_errors => true}

gui_switch = false

unless gui_switch
  Capybara.default_driver = :poltergeist
  Capybara.javascript_driver = :poltergeist
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, polterops)
  end
end