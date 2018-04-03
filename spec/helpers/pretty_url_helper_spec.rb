require 'rails_helper'

describe PrettyUrlHelper do
  let(:group) { FactoryBot.create :formal_group }
  it "gives normal group url" do
    expect(group_url(group)).to include group.key
  end

  it "gives group handle url" do
    group.update(handle: "something")
    expect(group_url(group)).to include group.handle
  end

  it 'does not use handle for subgroup urls' do
    group.update(handle: "something")
    subgroup = FactoryBot.create :formal_group, parent: group
    expect(group_url(subgroup)).to_not include group.handle
  end
end
