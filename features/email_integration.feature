Feature: email integration

Scenario: User replies to at_mention to post to discussion

  Given I have been at mentioned in a discussion
  And I receive an email with a reply-to token
  When I reply to that email saying "Hell yes!"
  Then my reply should become a discussion comment
