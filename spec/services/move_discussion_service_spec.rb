require 'rails_helper'
#require_relative '../../app/services/move_discussion_service'

describe MoveDiscussionService do
  let(:discussion) { create(:discussion, group: source_group) }
  let(:source_group) { create(:group) }
  let(:destination_group) { create(:group) }
  let(:user) { create(:user) }

  before do
    @mover = MoveDiscussionService.new(discussion: discussion,
                                       destination_group: destination_group,
                                       user: user)
  end

  context "valid?" do

    it "is false if user is not admin of source or author of the discussion" do
      destination_group.members << user
      expect(@mover.valid?).to eq false
    end

    it "is false user is not member of destination" do
      source_group.admins << user
      expect(@mover.valid?).to eq false
    end

    it "is true if user is admin of source group" do
      destination_group.members << user
      source_group.admins << user
      expect(@mover.valid?).to eq true
    end

    it "is true if user is author of discussion" do
      discussion.update author: user
      destination_group.members << user
      expect(@mover.valid?).to eq true
    end
  end

  context "move is valid" do
    before do
      @mover.should_receive(:valid?).and_return(true)
      allow(discussion).to receive(:group=){ allow(discussion).to receive(:group).and_return destination_group}
      allow(discussion).to receive(:public?).and_return(true)
      allow(discussion).to receive(:private=) { allow(discussion).to receive(:private).and_return false }
      allow(destination_group).to receive(:public_discussions_only?).and_return(true)
      allow(destination_group).to receive(:private_discussions_only?).and_return(false)
    end

    it "moves the discussion from source to destination" do
      discussion.should_receive(:save!)
      @mover.move!
      expect(discussion.group).to eq destination_group
    end
  end

end
