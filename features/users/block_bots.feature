Feature: Blocking bots
  As a Loomio user
  I don't want my preferred username to already be taken by some bot

  Scenario: A bot auto-fills all registration fields and gets an error
    Given I am on the user registration page
    And I fill in all the fields including the honeypot
    When I click "Create account"
    Then I should be redirected back to the registration page
    And I should see a message telling me not to fill in the honeypot field

  Scenario: A human fills in visible fields and gets doesn't get an error
    #presume this is already covered by other tests
