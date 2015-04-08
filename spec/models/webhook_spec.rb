require 'rails_helper'

describe Webhook do
  it { should belong_to :discussion }
  it { should validate_presence_of :uri }
  it { should validate_presence_of :discussion }
  it { should respond_to(:headers) } # we don't use headers yet; maybe for other services
end

