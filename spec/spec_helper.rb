require 'simplecov'
require File.expand_path("../support/spec_metrics", __FILE__)
SimpleCov.start 'rails'

require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

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
    config.use_transactional_fixtures = true

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false
  end

  require 'database_cleaner'
  DatabaseCleaner.strategy = :truncation

end

Spork.each_run do
  # This code will be run each time you run your specs.

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  # This code will be run each time you run your specs.
  DatabaseCleaner.clean

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
    motion.author = User.make!
  end
  unless motion.facilitator
    motion.facilitator = User.make!
  end
  unless motion.discussion
    motion.discussion = Discussion.new(title: "A Discussion")
    motion.discussion.group = motion.group
    motion.discussion.author = motion.author
    motion.discussion.save
  end
  motion.group.add_member!(motion.author)
  motion.group.add_member!(motion.facilitator)
  motion.save
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
  discussion.group.add_member! discussion.author
  discussion.save
  unless discussion.default_motion
    motion = create_motion(group: discussion.group)
    motion.discussion = discussion
    motion.save!
  end
  discussion
end
