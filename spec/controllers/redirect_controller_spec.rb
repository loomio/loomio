require 'rails_helper'

describe RedirectController do
  let(:group){ FactoryGirl.create :group, subdomain: 'example' }
  let(:discussion){ FactoryGirl.create :discussion }

  # before { request.host = "example.example.com" }
  #
  # it "group subdomain" do
  #   get :group_subdomain, subdomain: 'example'
  #   expect(response).to redirect_to(group_url(group))
  # end

  it "group key" do
    get :group_key, id: group.key
    expect(response).to redirect_to(group_url(group))
  end

  it "group id" do
    get :group_id, id: group.id
    expect(response).to redirect_to(group_url(group))
  end

  it 'discussion id' do
    get :discussion_id, id: discussion.id
    expect(response).to redirect_to(discussion_url(discussion))
  end

  it 'discussion key' do
    get :discussion_key, id: discussion.key
    expect(response).to redirect_to(discussion_url(discussion))
  end
end
