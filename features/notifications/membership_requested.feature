Feature: User sees notification that someone requested membership to their group

  Background:
    Given I am logged in
    And I am an admin of a group

  @javascript
  Scenario: Visitor requests membership
    Given a visitor has requested membership to the group
    When I visit the dashboard
    And I click the notifications dropdown
    Then I should see that the visitor requested access to the group

  @javascript
  Scenario: User requests membership
    Given a user has requested membership to the group
    When I visit the dashboard
    And I click the notifications dropdown
    Then I should see that the user requested access to the group

    When I click the membership request notification
    Then I should see the membership request page


