require "spec_helper"

describe "routes to the discussions controller" do
  let(:discussion) { create_discussion }

  it 'generates paths using the key & title attributes' do
    d = discussion
    d.title = "This is a tricky óñe & a hard test!"
    path = discussion_path(d)
    path.should == "/d/#{d.key}/#{d.title.parameterize}"
  end

  context 'no action in url' do
    it do
      expect(:get => '/d/abc123/lets-go-to-the-moon').
        to route_to(controller: 'discussions',
                        action: 'show',
                           key: 'abc123',
                          slug: 'lets-go-to-the-moon')
    end
    it do
      expect(:delete => '/d/abc123/lets-go-to-the-moon').
        to route_to(controller: 'discussions',
                        action: 'destroy',
                           key: 'abc123',
                          slug: 'lets-go-to-the-moon')
    end
  end

  context 'action in url' do
    before do
      DiscussionConstraint.any_instance.should_receive(:matches?).and_return(true)
    end

    it do
      expect(:get => '/d/abc123/lets-go-to-the-moon/new_proposal').
        to route_to(controller: 'discussions',
                        action: 'new_proposal',
                           key: 'abc123',
                          slug: 'lets-go-to-the-moon')
    end
    it do
      expect(:post => '/d/abc123/lets-go-to-the-moon/update_description').
        to route_to(controller: 'discussions',
                        action: 'update_description',
                           key: 'abc123',
                          slug: 'lets-go-to-the-moon')
    end
    it do
      expect(:post => '/d/abc123/lets-go-to-the-moon/add_comment').
        to route_to(controller: 'discussions',
                        action: 'add_comment',
                           key: 'abc123',
                          slug: 'lets-go-to-the-moon')
    end
    it do
      expect(:post => '/d/abc123/lets-go-to-the-moon/show_description_history').
        to route_to(controller: 'discussions',
                        action: 'show_description_history',
                           key: 'abc123',
                          slug: 'lets-go-to-the-moon')
    end
    it do
      expect(:post => '/d/abc123/lets-go-to-the-moon/edit_title').
        to route_to(controller: 'discussions',
                        action: 'edit_title',
                           key: 'abc123',
                          slug: 'lets-go-to-the-moon')
    end
    it do
      expect(:put => '/d/abc123/lets-go-to-the-moon/move').
        to route_to(controller: 'discussions',
                        action: 'move',
                           key: 'abc123',
                          slug: 'lets-go-to-the-moon')
    end
    it do
      expect(:put => '/d/abc123/lets-go-to-the-moon/update').
        to route_to(controller: 'discussions',
                        action: 'update',
                           key: 'abc123',
                          slug: 'lets-go-to-the-moon')
    end
  end

  context 'non-permitted route' do
    it do
      DiscussionConstraint.any_instance.should_receive(:matches?).and_return(false)
      expect(:delete => '/d/abc123/lets-go-to-the-moon/update').
        to_not route_to(controller: 'discussions',
                        action: 'update')
    end
  end


  context 'old urls' do
    it "routes correctly" do
      expect(:get => '/discussions/3' ).
        to route_to(controller: "discussions_redirect", action: "show", id: '3')
    end
  end
end
