Feature: Missed yesterday email
  Background:
    Given I am an existing Loomio user
    And I am a member of a group
    And I am subscribed to the missed yesterday email

  Scenario: User receives missed yesterday email
    Given there is a new discussion in the group
    When the missed yesterday email is sent
    Then I should get an email updating me of the content

  Scenario: User gets no email when no activity
    When the missed yesterday email is sent
    Then I should not get a missed yesterday email
