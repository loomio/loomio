require 'test_helper'

class EmailHelperTest < ActiveSupport::TestCase
  include EmailHelper
  include Rails.application.routes.url_helpers

  setup do
    ENV['REPLY_HOSTNAME'] = 'replyhostname.com'
    @user = users(:admin)
    @group = groups(:group)
    @author = users(:admin)
    @discussion = discussions(:discussion)
    @user.update_columns(email_api_key: 'abc123')
    ActionMailer::Base.deliveries.clear
  end

  def default_url_options
    { host: 'localhost', port: 3000 }
  end

  test "reply_to_address gives correct format for discussion" do
    output = reply_to_address(model: @discussion, user: @user)
    assert_equal "d=#{@discussion.id}&u=#{@user.id}&k=#{@user.email_api_key}@replyhostname.com", output
  end

  test "reply_to_address gives correct format for a comment" do
    comment = Comment.new(parent: @discussion, body: "Test comment")
    CommentService.create(comment: comment, actor: @author)
    output = reply_to_address(model: comment, user: @user)
    assert_equal "pt=c&pi=#{comment.id}&d=#{@discussion.id}&u=#{@user.id}&k=#{@user.email_api_key}@replyhostname.com", output
  end

  test "polymorphic_url returns a discussion url" do
    assert_match "/d/#{@discussion.key}", send(:polymorphic_url, @discussion)
  end

  test "polymorphic_url returns a group url for group without handle" do
    group = Group.create!(name: "No Handle Group #{SecureRandom.hex(4)}")
    group.update_column(:handle, nil)
    assert_match "/g/#{group.key}", send(:polymorphic_url, group)
  end

  test "polymorphic_url returns a group handle url" do
    assert_match "/#{@group.handle}", send(:polymorphic_url, @group)
  end

  test "polymorphic_url returns a comment url" do
    comment = Comment.new(parent: @discussion, body: "Test comment")
    CommentService.create(comment: comment, actor: @author)
    assert_match "/c/#{comment.id}", send(:polymorphic_url, comment)
  end

  test "polymorphic_url can accept a utm hash" do
    comment = Comment.new(parent: @discussion, body: "Test comment")
    CommentService.create(comment: comment, actor: @author)
    assert_match "utm_medium=wark", send(:polymorphic_url, comment, { utm_medium: "wark" })
  end
end
