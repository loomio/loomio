require "rails_helper"

describe "Events::Position" do
  let(:group) { FactoryGirl.create :formal_group }
  let(:discussion) { create :discussion, group: group }
  let(:comment1) { create :comment, discussion: discussion }
  let(:comment2) { create :comment, discussion: discussion }
  let(:comment3) { create :comment, discussion: discussion }

  it "gives events with a parent_id a pos sequence" do
    e1 = Event.create(kind: "new_comment", parent_id: 1, eventable: comment1)
    e2 = Event.create(kind: "new_comment", parent_id: 1, eventable: comment2)
    e3 = Event.create(kind: "new_comment", parent_id: 1, eventable: comment3)
    expect(e1.reload.position).to be 1
    expect(e2.reload.position).to be 2
    expect(e3.reload.position).to be 3
  end

  it "reorders if parent changes" do
    e1 = Event.create(kind: "new_comment", parent_id: 1, eventable: comment1)
    e2 = Event.create(kind: "new_comment", parent_id: nil, eventable: comment2)
    expect(e1.reload.position).to be 1
    e2.update(parent_id: 1)
    expect(e2.reload.position).to be 2
  end

  it "recounts child_count if parent changes" do
    e1 = Event.create(kind: "new_comment", parent_id: nil, eventable: comment1)
    e2 = Event.create(kind: "new_comment", parent_id: nil, eventable: comment2)
    expect(e1.reload.position).to be 0
    e2.update(parent_id: e1.id)
    expect(e1.reload.child_count).to be 1
  end
end
