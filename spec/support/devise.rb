module ControllerHelpers
  def sign_in(user = double('user'))
    if user.nil?
      allow(request.env['warden']).to receive(:authenticate!) { throw(:warden, scope: :user) }
      allow(controller).to            receive(:current_user)  { nil }
    else
      allow(request.env['warden']).to receive(:authenticate!) { user }
      allow(controller).to            receive(:current_user)  { user }
    end
  end
end

RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
  config.include ControllerHelpers, :type => :controller
end
