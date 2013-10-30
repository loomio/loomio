require 'spec_helper'

describe Event do
  describe "#belongs_to(user)?" do
    context "event was triggered by my action" do
      let(:user) { stub_model(User)}
      it "returns true" do
        event = Event.new
        event.stub(:user).and_return(user)
        event.belongs_to?(user).should be_true
      end
    end

    context "event was not triggered by my action" do
      let(:user) { stub_model(User) }
      let(:other_user) { stub_model(User) }
      it "returns false" do
        event = Event.new
        event.stub(:user).and_return(user)
        event.belongs_to?(other_user).should be_false
      end
    end
  end

end
