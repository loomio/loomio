Feature: Admin deletes post
  As an admin
  So that I can remove inappropriate content
  I want to be able to delete other user's comments

  @javascript
  Scenario: Admin deletes another users comment
    Given I am logged in
    And I am an admin of a group with a discussion
    And the discussion has a comment
    And I am on the discussion page
    When I click the delete button on a post
    Then I should no longer see the post in the discussion
