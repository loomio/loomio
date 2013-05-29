Feature: Invitation token not found
  Scenario: User loads unknown invitation token and is told it was not found
    When I load an unknown invitation link
    Then I should be told the invitation token was not found
