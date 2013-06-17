Feature: deliver emails in the user's prefered language
  As a member of a group
  So that I can participate fully
  Emails should be delivered in my prefered language

  Background:
    Given "John" is a user with an English language preference
    And "Eduardo" is a user with a Spanish language preference
    And "Viv" is a user without a specified language preference

  Scenario: new discussion email
    Given "John" has created a new discussion
    Then the new discussion email should be delivered to "Eduardo" in Spanish
    And the new discussion email should be delivered to "Viv" in English

  Scenario: new proposal email
    Given "Eduardo" has created a new proposal
    Then the new proposal email should be delivered to "Viv" in Spanish
    And the new proposal email should be delivered to "John" in English

  Scenario: proposal blocked email
    Given "John" has blocked a proposal started by "Eduardo"
    Then the proposal blocked email should be delivered to "Eduardo" in Spanish
    Given "Eduardo" has blocked a proposal started by "John"
    Then the proposal blocked email should be delivered to "John" in English
    Given "Viv" has blocked a proposal started by "Eduardo"
    Then the proposal blocked email should be delivered to "Eduardo" in Spanish

  Scenario: proposal closing soon email
    Given the proposal started by "Eduardo" is closing soon
    Then "John" should receive the proposal closing soon email in English
    And "Viv" should receive the proposal closing soon email in Spanish

  Scenario: proposal closed email
    Given "Eduardo" has closed their proposal
    Then the proposal closed email should be delivered to "Viv" in Spanish
    And the proposal closed email should be delivered to "John" in English

  Scenario: membership request email
    When "John" requests membership to the group
    Then the membership request email should be delivered to "Eduardo" in Spanish
    Then the membership request email should be delivered to "Viv" in English

  Scenario: group membership approved email
    When "John" approves "Eduardo"s group membership request
    Then the group membership request approved email should be delivered in Spanish
    When "Eduardo" approves "John"s group membership request
    Then the group membership request approved email should be delivered in English

  Scenario: daily activity email
    When the daily activity email is sent
    Then "Eduardo" should receive the daily activity email in Spanish
    And "John" should receive the daily activity email in English
    And "Viv" should receive the daily activity email in English

  Scenario: mentioned email
    When "John" mentions "Eduardo" in a comment
    Then "Eduardo" should receive the mention email in Spanish
    When "Eduardo" mentions "Viv" in a comment
    Then "Viv" should receive the mention email in Spanish
    When "Eduardo" mentions "John" in a comment
    Then "John" should receive the mention email in English

  Scenario: group membership request approved email
    When "John" requests to join a group administered by "Eduardo"
    Then "John" should receive the membership request approval email in English
    When "Eduardo" requests to join a group administered by "John"
    Then "Eduardo" should receive the membership request approval email in Spanish

  Scenario: Group announcement email
    When "Eduardo" makes an announcement to the group
    Then "John" should receive the group email in English
    And "Viv" should receive the group email in Spanish

  @javascript
  Scenario: Group request verification email
    Given "Joan" is a logged-out user
    When they visit the Request New Group page
    And their browser header indicates a Spanish language preference
    When they fill in and submit the Request New Group Form
    Then they should receive the group request verification email in Spanish
