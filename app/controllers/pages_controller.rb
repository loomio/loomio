class PagesController < ApplicationController
  def home
    @diaspora_group = Group.find_by_id(194)
    @blag_group = Group.find_by_id(1031)
    @loomio_community_group = Group.find_by_id(3)
  end

  def about
  end

  def blog
  end

  def privacy
  end

  def pricing
  end

  def terms_of_service
  end

  def third_parties
  end
end
