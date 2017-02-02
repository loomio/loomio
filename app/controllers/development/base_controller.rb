class Development::BaseController < ApplicationController
  include Development::BaseHelper
  before_filter :ensure_testing_environment
  before_filter :cleanup_database
end
