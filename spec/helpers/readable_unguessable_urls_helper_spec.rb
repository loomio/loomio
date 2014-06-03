require 'spec_helper'


describe ReadableUnguessableUrlsHelper do
  let(:request) { double(:request, subdomain: 'www', port: 80, ssl?: false, host: 'www.example.com', domain: 'example.com') }

  before do
    @old_action_mailer_default_url_options = ActionMailer::Base.default_url_options
    ActionMailer::Base.default_url_options = { host: 'www.example.com', port: 3000 }
    helper.stub(:request).and_return(request)
  end

  after do
    ActionMailer::Base.default_url_options = @old_action_mailer_default_url_options
  end


  describe "group_url" do
    before do
      ENV['DEFAULT_SUBDOMAIN'] = 'www'
    end

    after do
      ENV.delete('DEFAULT_SUBDOMAIN')
    end

    subject { helper.group_url(group) }

    describe "for group with no subdomain" do
      let(:group) { create(:group, key: 'key', subdomain: nil, name: 'name') }

      context "used within an email" do
        before { helper.stub(:request).and_return(nil) }
        it{ should == "http://www.example.com:3000/g/key/name" }
      end

      context "used on default subdomain" do
        before { request.stub(:subdomain).and_return('www') }
        it{ should == "http://www.example.com/g/key/name" }
      end

      context "used on custom subdomain" do
        before { request.stub(:subdomain).and_return('custom') }
        it{ should == "http://www.example.com/g/key/name" }
      end
    end

    describe "for group with subdomain" do
      let(:group) { create(:group, name: 'name', key: 'key', subdomain: 'custom') }

      context "used within an email" do
        before { helper.stub(:request).and_return(nil) }
        it{ should == "http://custom.example.com:3000" }
      end

      context "used on default subdomain" do
        before { request.stub(:subdomain).and_return('www') }
        it{ should == "http://custom.example.com" }
      end

      context "used on custom subdomain" do
        before { request.stub(:subdomain).and_return('custom') }
        it{ should == "http://custom.example.com" }
      end
    end

    describe "for subgroup of group with subdomain" do
      let(:parent_group) { create(:group, name: 'parent', key: 'parent_key', subdomain: 'parent_subdomain') }
      let(:group) { create(:group, name: 'subgroup', key: 'key', parent: parent_group) }

      context "used within an email" do
        before { helper.stub(:request).and_return(nil) }
        it{ should == "http://parent_subdomain.example.com:3000/g/key/parent-subgroup" }
      end

      context "used on default subdomain" do
        before { request.stub(:subdomain).and_return('www') }
        it{ should == "http://parent_subdomain.example.com/g/key/parent-subgroup" }
      end

      context "used on custom subdomain" do
        before { request.stub(:subdomain).and_return('parent_subdomain') }
        it{ should == "http://parent_subdomain.example.com/g/key/parent-subgroup" }
      end
    end
  end


  describe "group_path" do
    before do
      ENV['DEFAULT_SUBDOMAIN'] = 'www'
    end

    after do
      ENV.delete('DEFAULT_SUBDOMAIN')
    end

    subject { helper.group_path(group) }
    describe "for group with no subdomain" do
      let(:group) { create(:group, key: 'key', subdomain: nil, name: 'name') }

      context "used on default subdomain", focus: true do
        before { request.stub(:subdomain).and_return('www') }
        it{ should == "/g/key/name" }
      end

      context "used on custom subdomain" do
        before { request.stub(:subdomain).and_return('custom') }
        it{ should == "http://www.example.com/g/key/name" }
      end
    end

    describe "for group with subdomain" do
      let(:group) { create(:group, name: 'name', key: 'key', subdomain: 'custom') }

      context "used on default subdomain" do
        before { request.stub(:subdomain).and_return('www') }
        it{ should == "http://custom.example.com" }
      end

      context "used on custom subdomain" do
        before { request.stub(:subdomain).and_return('custom') }
        it{ should == "/" }
      end
    end

    describe "for subgroup of group with subdomain" do
      let(:parent_group) { create(:group, name: 'parent', key: 'parent_key', subdomain: 'parent-domain') }
      let(:group) { create(:group, name: 'subgroup', key: 'key', parent: parent_group) }

      context "used on default subdomain" do
        before { request.stub(:subdomain).and_return('www') }
        it{ should == "http://parent-domain.example.com/g/key/parent-subgroup" }
      end

      context "used on custom subdomain" do
        before { request.stub(:subdomain).and_return('parent-domain') }
        it{ should == "/g/key/parent-subgroup" }
      end
    end
  end

  describe "group_path when no default subdomain" do
    let(:request) { double(:request, subdomain: nil, port: 80, ssl?: false, host: 'example.com', domain: 'example.com') }

    before do
      ENV.delete('DEFAULT_SUBDOMAIN')
    end

    subject { helper.group_path(group) }
    describe "for group with no subdomain" do
      let(:group) { create(:group, key: 'key', subdomain: nil, name: 'name') }

      context "used on default subdomain", focus: true do
        before { request.stub(:subdomain).and_return(nil) }
        it{ should == "/g/key/name" }
      end

      context "used on custom subdomain" do
        before { request.stub(:subdomain).and_return('custom') }
        it{ should == "http://example.com/g/key/name" }
      end
    end

    describe "for group with subdomain" do
      let(:group) { create(:group, name: 'name', key: 'key', subdomain: 'custom') }

      context "used on default subdomain" do
        before { request.stub(:subdomain).and_return(nil) }
        it{ should == "http://custom.example.com" }
      end

      context "used on custom subdomain" do
        before { request.stub(:subdomain).and_return('custom') }
        it{ should == "/" }
      end
    end

    describe "for subgroup of group with subdomain" do
      let(:parent_group) { create(:group, name: 'parent', key: 'parent_key', subdomain: 'parent-domain') }
      let(:group) { create(:group, name: 'subgroup', key: 'key', parent: parent_group) }

      context "used on default subdomain" do
        before { request.stub(:subdomain).and_return(nil) }
        it{ should == "http://parent-domain.example.com/g/key/parent-subgroup" }
      end

      context "used on custom subdomain" do
        before { request.stub(:subdomain).and_return('parent-domain') }
        it{ should == "/g/key/parent-subgroup" }
      end
    end
  end
end

