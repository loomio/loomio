require "spec_helper"

describe "routes to the groups controller" do
  let(:group) { create :group }

  it 'generates paths using the key & full_name' do
    g = group
    path = group_path(g)
    path.should == "/g/#{g.key}/#{g.full_name.parameterize}"
  end

  context 'no action in url' do
    it do
      expect(:get => '/g/abc123/the-party-house').
        to route_to(controller: 'groups',
                        action: 'show',
                           key: 'abc123',
                          slug: 'the-party-house')
    end
    it do
      expect(:put => '/g/abc123/the-party-house').
        to route_to(controller: 'groups',
                        action: 'update',
                           key: 'abc123',
                          slug: 'the-party-house')
    end
    it do
      expect(:delete => '/g/abc123/the-party-house').
        to route_to(controller: 'groups',
                        action: 'destroy',
                           key: 'abc123',
                          slug: 'the-party-house')
    end
  end

  context 'action in url' do
    before do
      GroupConstraint.any_instance.should_receive(:matches?).and_return(true)
    end

    it do
      {:post => '/g/abc123/the-party-house/add_members'}.
        should route_to(controller: 'groups',
                            action: 'add_members',
                               key: 'abc123',
                              slug: 'the-party-house')
    end
    it do
      expect(:post => '/g/abc123/the-party-house/hide_next_steps').
        to route_to(controller: 'groups',
                        action: 'hide_next_steps',
                           key: 'abc123',
                          slug: 'the-party-house')
    end
    it do
      expect(:get => '/g/abc123/the-party-house/add_subgroups').
        to route_to(controller: 'groups',
                        action: 'add_subgroups',
                           key: 'abc123',
                          slug: 'the-party-house')
    end
    it do
      expect(:post => '/g/abc123/the-party-house/email_members').
        to route_to(controller: 'groups',
                        action: 'email_members',
                           key: 'abc123',
                          slug: 'the-party-house')
    end
    it do
      {:post => '/g/abc123/the-party-house/edit_description'}.
        should route_to(controller: 'groups',
                            action: 'edit_description',
                               key: 'abc123',
                              slug: 'the-party-house')
    end
    it do
      expect(:delete => '/g/abc123/the-party-house/leave_groups').
        to route_to(controller: 'groups',
                        action: 'leave_groups',
                           key: 'abc123',
                          slug: 'the-party-house')
    end
    it do
      expect(:get => '/g/abc123/the-party-house/members_autocomplete').
        to route_to(controller: 'groups',
                        action: 'members_autocomplete',
                           key: 'abc123',
                          slug: 'the-party-house')
    end
    it do
      expect(:get => '/g/abc123/the-party-house/edit').
        to route_to(controller: 'groups',
                        action: 'edit',
                           key: 'abc123',
                          slug: 'the-party-house')
    end
    it do
      expect(:post => '/g/abc123/the-party-house/archive').
        to route_to(controller: 'groups',
                        action: 'archive',
                           key: 'abc123',
                          slug: 'the-party-house')
    end
  end

  context 'non-permitted route' do
    it do
      GroupConstraint.any_instance.should_receive(:matches?).and_return(false)
      expect(:delete => '/g/abc123/the-party-house/update').
        to_not route_to(controller: 'groups',
                            action: 'update')
    end
  end

  context 'old urls' do
    it "routes correctly for old urls" do
      expect(:get => '/group/3' ).
        to route_to(controller: "groups_redirect", action: "show", id: '3')
    end
  end
end