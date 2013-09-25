Feature: Membership request approved notification
  As a user
  So that I am aware when a membership request I have made has been approved
  I want to see a notification

  @javascript
  Scenario: User sees membership request approved notification
    Given I am an existing Loomio user
    And I have requested membership to a group
    And my membership request has been approved
    Then I should get a membership request approved notificaiton
