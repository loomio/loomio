Feature: Attachments on comments
  In order to be able to share relevant documents and files
  As a user
  I need to be able to attach files to comments

  # NOTE: We haven't implemented these steps because it would be a pain,
  #       however, the cuke is useful as documentation of the feature
  #       so that we can manually test each scenario when we change
  #       the feature.

  Background:
    Given I am logged in
    And I belong to a group with a discussion
    And I am on the discussion page

#  Scenario: User attaches file and posts comment
#    When I attach a file
#    And I post a comment
#    Then I should see the posted comment with the attachment
#    And the attachment should be saved to the database

  Scenario: User attaches file, cancels upload and posts comment
    When I attach a file and cancel the upload
    And I post a comment
    Then I should see the posted comment without an attachment

#  Scenario: User attaches file, removes attachment and posts comment
#    When I attach a file
#    And remove the file
#    And I post a comment
#    Then I should see the posted comment without an attachment

  Scenario: User cannot attach oversized file
    When I try to attach an oversized file
    Then I should be told the file is oversized

#  Scenario: User cannot attach two files at once
#    When I attach a file
#    And I try to attach another file while the previous file is still uploading
#    Then I should be told that I cannot attach a file whilst the other file is uploading
