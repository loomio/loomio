require 'rails_helper'

describe Api::V1::TrialsController do
  it "params[:user_email] invalid" do
    post :create, params: {
      user_email: "invalid_email",
      user_name: "normal name"
    }
    expect(response.status).to eq 422
    expect(JSON.parse(response.body)["errors"]["user_email"]).to include("Not a valid email")
  end

  it "params[:user_email] exists" do
    User.create!(email: "verified@example.com", email_verified: true)
    post :create, params: {
      user_email: "verified@example.com",
      user_name: "normal name"
    }
    expect(response.status).to eq 422
    expect(JSON.parse(response.body)["errors"]["user_email"]).to include("Email address already exists. Please sign in to continue.")
  end

  it "verifies accept legal" do
    post :create, params: {
      user_name: "Jimmy",
      user_email: "jimmy1@example.com",
      group_name: "Jim group",
      group_description: "Make decisions",
      group_category: "boards",
      group_how_did_you_hear_about_loomio: "I work there",
      user_email_newsletter: true,
      user_legal_accepted: false
    }
    expect(response.status).to eq 422
    expect(JSON.parse(response.body)["errors"]["user_legal_accepted"]).to include("must be accepted")
  end

  it "creates new user and group and sends login email" do
    post :create, params: {
      user_name: "Jimmy",
      user_email: "jimmy@example.com",
      group_name: "Jim group",
      group_description: "Make decisions",
      group_category: "boards",
      group_how_did_you_hear_about_loomio: "I work there",
      user_email_newsletter: true,
      user_legal_accepted: true
    }
    expect(response.status).to eq 200
    user = User.find_by(email: 'jimmy@example.com')
    expect(user.name).to eq "Jimmy"
    expect(user.email_newsletter).to be true
    group = user.adminable_groups.first
    expect(JSON.parse(response.body)['group_path']).to eq "/#{group.handle}"
    expect(group.name).to eq "Jim group"
    expect(group.handle).to eq "jim-group"
    expect(group.description).to include "Make decisions"
    expect(group.category).to eq "boards"
    expect(group.info['how_did_you_hear_about_loomio']).to eq "I work there"
  end

  # test newsletter bool
end
