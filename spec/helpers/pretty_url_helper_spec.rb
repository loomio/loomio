require 'rails_helper'

describe PrettyUrlHelper do
  let(:group) { FactoryBot.create :formal_group, handle: nil}
  it "gives normal group url" do
    expect(group_url(group)).to include group.key
  end

  it "gives group handle url" do
    group.update(handle: "something")
    expect(group_url(group)).to include group.handle
  end

  it 'supports handles for subgroup urls' do
    group.update(handle: "something")
    subgroup = FactoryBot.create :formal_group, parent: group.reload
    expect(group_url(subgroup)).to include subgroup.handle
  end
end
