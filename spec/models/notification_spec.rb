require 'spec_helper'

describe Notification do
  it { should belong_to(:user) }
  it { should belong_to(:discussion) }
  it { should belong_to(:comment) }
  it { should belong_to(:motion) }
  it { should validate_presence_of(:kind) }

  it { should allow_value("new_discussion").for(:kind) }
  it { should_not allow_value("blah").for(:kind) }

  describe "new_discussion!" do
    let(:discussion) { create_discussion }
    let(:user) { User.make! }
    subject { Notification.new_discussion!(discussion, user) }

    specify { subject.kind == "new_discussion" }
    specify { subject.discussion == discussion }
  end
end
