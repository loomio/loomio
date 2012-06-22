require 'spec_helper'

describe Notification do
  it { should belong_to(:user) }
  it { should belong_to(:discussion) }
  it { should belong_to(:comment) }
  it { should belong_to(:motion) }
  it { should validate_presence_of(:kind) }

  it { should allow_value("new_discussion").for(:kind) }
  it { should_not allow_value("blah").for(:kind) }
end
