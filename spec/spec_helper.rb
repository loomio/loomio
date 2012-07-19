require 'simplecov'
require File.expand_path("../support/spec_metrics", __FILE__)
SimpleCov.start 'rails'

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
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = false

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

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

  #DatabaseCleaner.clean

end


def create_motion(*args)
  unless args.empty?
    motion = Motion.make
    args[0].each_pair do |key, value|
      motion.send("#{key}=", value)
    end
  else
    motion = Motion.make
  end
  unless motion.author
    motion.author = User.make
    motion.author.save
  end
  unless motion.facilitator
    motion.facilitator = motion.author
  end
  unless motion.discussion
    discussion = Discussion.new(title: "A Discussion")
    discussion.author = motion.author
    discussion.group = Group.make
    discussion.group.add_member!(discussion.author)
    discussion.group.save
    discussion.save
    motion.discussion = discussion
  end
  motion.group.add_member!(motion.author)
  motion.group.add_member!(motion.facilitator)
  motion.save
  motion.reload
  motion
end

def create_discussion(*args)
  unless args.empty?
    discussion = Discussion.new
    args[0].each_pair do |key, value|
      discussion.send("#{key}=", value)
    end
  else
    discussion = Discussion.new
  end
  unless discussion.group
    discussion.group = Group.make
    discussion.group.save
  end
  unless discussion.author
    discussion.author = User.make
    discussion.author.save
  end
  unless discussion.title
    discussion.title = "Title of discussion!"
  end
  discussion.group.add_member! discussion.author
  #unless discussion.current_motion
    #motion = create_motion(discussion: discussion)
  #end
  discussion.save
  discussion
end
