require 'rails_helper'

describe API::V1::TrialsController do
  describe "email does not exist" do
    it "creates new user and group and sends login email" do
      post :create, params: {
        user_name: "Jimmy",
        user_email: "jimmy@example.com",
        group: {name: "Jim group", description: "Make decisions" },
        group_category: "boards",
        how_did_you_hear_about_loomio: "I work there",
        newsletter: true,
      }
      expect(response.status).to eq 200
      user = User.find_by(email: 'jimmy@example.com')
      expect(user.name).to eq "Jimmy"
      expect(user.email_newsletter).to be true
      group = user.adminable_groups.first
      expect(group.name).to eq "Jim group"
      expect(group.handle).to eq "jim-group"
      expect(group.description).to include "Make decisions"
      expect(group.category).to eq "boards"
      expect(group.info['how_did_you_hear_about_loomio']).to eq "I work there"
    end
  end

  # test email is unverified
  # test email is verified

  # test newsletter bool
  # test recaptcha?

end
