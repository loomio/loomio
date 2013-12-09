require "spec_helper"

describe "routes to the discussions controller" do
  let(:group) { create :group }

  it 'generates paths using the key & full_name' do
    g = group
    path = group_path(g)
    path.should == "/g/#{g.key}/#{g.full_name.parameterize}"
  end

  it "routes correctly for old urls" do
    expect(:get => '/group/3' ).
      to route_to(controller: "groups_redirect", action: "show", id: '3')
  end

  it "routes correctly for new urls" do
    key = group.key
    slug = group.full_name.parameterize
    expect(:get => new_group_membership_request_path(group)).
      to route_to(controller: 'groups', action: 'show', key: key, slug:slug)

    expect(:get => new_group_membership_request_path(group)).
      to route_to(controller: 'groups/membership_requests', action: 'new', key: key, slug: slug)
  end
end