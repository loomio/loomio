require 'spec_helper'

describe EmailIntegration do
  let(:email_integration) { create :email_integration }

  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:email_integrable) }
end
