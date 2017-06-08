require 'rails_helper'

describe Visitor do
  let(:visitor) { build(:visitor) }

  it "cannot have the DECIDE_EMAIL as email" do
    visitor.email = ENV['DECIDE_EMAIL']
    visitor.should have(1).errors_on(:email)
  end
end
