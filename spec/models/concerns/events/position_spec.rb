require "rails_helper"

describe "Events::Position" do
  let(:group) { FactoryGirl.create :formal_group }
  let(:discussion) { create :discussion, group: group }
  let(:comment0) { create :comment, discussion: discussion }
  let(:comment1) { create :comment, discussion: discussion }

  it "gives events with a parent_id a pos sequence" do
    e0 = Event.create(kind: "new_comment", parent_id: 1, eventable: comment0)
    e1 = Event.create(kind: "new_comment", parent_id: 1, eventable: comment1)
    e2 = Event.create(kind: "new_comment", parent_id: 1, eventable: comment1)
    expect(e0.reload.position).to be 0
    expect(e1.reload.position).to be 1
    expect(e2.reload.position).to be 2
  end

  it "reorders if parent changes" do
    e0 = Event.create(kind: "new_comment", parent_id: 1, eventable: comment0)
    e1 = Event.create(kind: "new_comment", parent_id: nil, eventable: comment1)
    expect(e1.reload.position).to be 0
    e1.update(parent_id: 1)
    expect(e1.reload.position).to be 1
  end

  it "recounts child_count if parent changes" do
    e0 = Event.create(kind: "new_comment", parent_id: nil, eventable: comment0)
    e1 = Event.create(kind: "new_comment", parent_id: nil, eventable: comment1)
    expect(e0.reload.position).to be 0
    e0.update(parent_id: e1.id)
    expect(e1.reload.child_count).to be 1
  end
end
