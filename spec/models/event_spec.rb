require 'spec_helper'

describe Event do
  describe 'validating presence of discussion_item_number' do
    before do
      @event = Event.new
      @discussion = FactoryGirl.create(:discussion)
    end

    context 'discussion is present' do
      before do
        @event.discussion = @discussion
        @event.valid?
      end

      it 'validates presence of discussion_item_number' do
        @event.should have(1).error_on(:discussion_item_number)
      end
    end

    context 'discussion is absent' do
      before do
        @event.discussion = @discussion
        @event.save
      end

      it 'does not validate presence of discussion_item_number' do
        @event.should_not have(1).error_on(:discussion_item_number)
      end
    end
  end

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
