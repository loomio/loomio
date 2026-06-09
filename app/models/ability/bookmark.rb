module Ability::Bookmark
  def initialize(user)
    super(user)

    can :show, ::Bookmark do |bookmark|
      user_is_author_of?(bookmark)
    end

    can :update, ::Bookmark do |bookmark|
      user.is_logged_in? &&
      user_is_author_of?(bookmark) &&
      can?(:show, bookmark.bookmarkable)
    end

    can :destroy, ::Bookmark do |bookmark|
      user_is_author_of?(bookmark)
    end
  end
end
