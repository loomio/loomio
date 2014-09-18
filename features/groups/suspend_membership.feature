Feature: Suspend Membership

  Scenario: Group coordinator suspends user account
    Given I am the logged in admin of a group
    And   there is a group member causing a ruckus
    When  I suspend their group membership
    Then  the suspended member loses their membership privileges
