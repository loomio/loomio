Feature: We The People portal

  Scenario: User loads We The People index
    Given there is a We The People campaign record
    When I load We The People index
    Then I should see the We The People index

  @javascript
  Scenario: User asks to participate in We The People
    Given there is a We The People campaign record
    When I load We The People index
    And I click "Click here to participate"
    And I fill in and submit the form with my name and email
    Then an email should be sent to the campaign manager
    And a campaign signup should be saved

  Scenario: User chooses to look at the existing discussions
    Given there is a We The People campaign record
    When I load We The People index
    And I click "Take a look"
    Then I should see the We The People group page
