require 'rails_helper'

def expect_text(selector, val)
  Nokogiri::HTML(ActionMailer::Base.deliveries.last.body.parts.last.decoded).css(selector).to_s
end

def expect_element(selector)
  Nokogiri::HTML(ActionMailer::Base.deliveries.last.body.parts.last.decoded).css(selector).to_s.length > 0
end

describe Dev::NightwatchController do
  it 'catch_up' do
    get :setup_thread_catch_up
    expect_text('.thread-mailer__body', "Item removed")
    expect_text('.thread-mailer__body', "A description for this discussion. Should this be <em>rich</em>?")
  end
  it 'discussion_announced' do
    get :setup_discussion_mailer_discussion_announced_email
    expect_text('.thread-mailer__subject', "invited you to join")
    expect_text('.thread-mailer__body', "A description for this discussion. Should this <em>rich</em>?")
  end

  it 'invitation_created' do
    get :setup_discussion_mailer_invitation_created_email
    expect_text('.thread-mailer__subject', "invited you to join")
    expect_text('.thread-mailer__body', "A description for this discussion. Should this <em>rich</em>?")
  end

  it 'new_comment' do
    get :setup_discussion_mailer_new_comment_email
    expect_text('.thread-mailer__subject', "Jennifer Grey commented in: What star sign are you?")
    expect_text('.thread-mailer__body', "hello patrick.")
  end

  it 'comment_replied_to' do
    get :setup_discussion_mailer_comment_replied_to_email
    expect_text('.thread-mailer__subject', "Patrick Swayze replied to you in: What star sign are you?")
    expect_text('.thread-mailer__body', "why, hello there jen")
  end

  it 'user_mentioned' do
    get :setup_discussion_mailer_user_mentioned_email
    expect_text('.thread-mailer__subject', "Jennifer Grey mentioned you in What star sign are you?")
    expect_text('.thread-mailer__body', "hey @patrickswayze wanna dance?")
  end

end
