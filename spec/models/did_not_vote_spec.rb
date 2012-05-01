require 'spec_helper'

describe DidNotVote do
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:motion) }
  it { should belong_to(:motion) }
  it { should belong_to(:user) }
end
