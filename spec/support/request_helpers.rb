# spec/support/request_helpers.rb
require 'spec_helper'
include Warden::Test::Helpers
 
module RequestHelpers
  def create_logged_in_user
    user = create(:user)
    login(user)
    user
  end
 
  def login(user)
    login_as user, scope: :user
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, :type => :request
end

