require 'rails_helper'

# External dependencies
require 'active_support/core_ext/object/blank'
require 'active_support/concern'

require_relative '../../../app/models/concerns/avatar_initials'

class DummyUser
  include AvatarInitials
  attr_accessor :name, :email, :deactivated_at, :avatar_initials
end

describe AvatarInitials do
  let(:user) { DummyUser.new }

  before do
    user.name = "Rob Gob"
    user.email = "rob@gob.com"
  end

  describe "#set_avatar_initials" do
    it "sets avatar_initials to 'DU' if deactivated_at is true (a date is present)" do
      user.deactivated_at = "20/12/2002"
      user.set_avatar_initials
      expect(user.avatar_initials).to eq "DU"
    end

    it "sets avatar_initials to the first two characters in all caps of the email if the user's name is email" do
      user.set_avatar_initials
      expect(user.avatar_initials).to eq "RG"
    end

    it "returns the first three initials of the stored name" do
      user.name = "Bob bobby sinclair deebop"
      user.set_avatar_initials
      expect(user.avatar_initials).to eq "BBS"
    end

    it "returns the first two characters of their email if they have no name" do
      user.name = nil
      user.set_avatar_initials
      expect(user.avatar_initials).to eq "RO"
    end
  end
end
