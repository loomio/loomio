# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Loomio::Application.initialize!

GC::Profiler.enable
