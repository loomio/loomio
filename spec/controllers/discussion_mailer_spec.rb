require 'rails_helper'

require_relative './mailer_helpers'

describe Dev::NightwatchController do
  render_views

  # it 'catch_up' do
  #   get :setup_thread_catch_up
  #   expect_text_no_tags('main', "Dirty Dancing Shoes")
  #   expect_text_no_tags('main', "How to use Loomio")
  #   expect_text_no_tags('main', "Demonstration proposal")
  #   expect_text_no_tags('main', "What star sign are you?")
  # end

  it 'discussion_created' do
    get :setup_discussion_mailer_discussion_created_email
    expect_text_no_tags('.base-mailer__event-headline', "started a thread")
    expect_text_no_tags('.thread-mailer__body', "A description for this discussion. Should this be rich?")
  end

  it 'discussion_announced' do
    get :setup_discussion_mailer_discussion_announced_email
    expect_text_no_tags('.base-mailer__event-headline', "invited you to a thread")
    expect_text_no_tags('.thread-mailer__body', "A description for this discussion. Should this be rich?")
  end

  it 'invitation_created' do
    get :setup_discussion_mailer_invitation_created_email
    expect_text_no_tags('.base-mailer__event-headline', "invited you to a thread")
    expect_text_no_tags('.thread-mailer__body', "A description for this discussion. Should this be rich?")
  end

  it 'new_comment' do
    get :setup_discussion_mailer_new_comment_email
    expect_text_no_tags('.base-mailer__event-headline', "Jennifer Grey commented in: What star sign are you?")
    expect_text_no_tags('.thread-mailer__body', "hello patrick.")
  end

  it 'comment_replied_to' do
    get :setup_discussion_mailer_comment_replied_to_email
    expect_text_no_tags('.base-mailer__event-headline', "Patrick Swayze replied to you")
    expect_text_no_tags('.thread-mailer__body', "why, hello there jen")
  end

  it 'user_mentioned' do
    get :setup_discussion_mailer_user_mentioned_email
    expect_text_no_tags('.base-mailer__event-headline', "Jennifer Grey mentioned you")
    expect_text_no_tags('.thread-mailer__body', "hey @patrickswayze wanna dance?")
  end

end
