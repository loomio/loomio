Feature: Viewing discussion lists

  Scenario: User without any groups views dashboard
    Given I am logged in
    When I visit the dashboard
    Then I should see "Start a group"

  Scenario: User and non-member views empty, join by approval group
    Given I am logged in
    When  I view an empty 'join by approval' group
    Then  I see message the group has no public discussions
    And   I see message to request membership

  Scenario: User and non-member views empty, join by invitation
    Given I am logged in
    When  I view an empty 'join by member invitation' group
    Then  I see message the group has no public discussions
    And   I see message that the group is invite by member only

  Scenario: User and member views empty group
    Given I am logged in
    And   I am a member of an empty group
    When  I visit the group
    Then  I see there are no discussions in the group
