require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

# Workaround for Spork issue #109 until pull-req #140 gets merged
AbstractController::Helpers::ClassMethods.module_eval do def helper(*args, &block); modules_for_helpers(args).each {|mod| add_template_helper(mod)}; _helpers.module_eval(&block) if block_given?; end end if Spork.using_spork?

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'

  # Fix for devise interfering with reloading the user model
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!) if Spork.using_spork?

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'

  RSpec.configure do |config|
    config.mock_with :rspec

    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run :focus => true
    config.run_all_when_everything_filtered = true

    config.include FactoryGirl::Syntax::Methods

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

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = false

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    # to make sure paper_trail data from one test doesn't spill over another
    config.before :each do
      PaperTrail.controller_info = {}
      PaperTrail.whodunnit = nil
    end

    config.before :suite do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before type: :request do
      DatabaseCleaner.strategy = :truncation
    end

    config.before do
      DatabaseCleaner.start
    end

    config.after do
      DatabaseCleaner.clean
    end
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

end
