Feature: Authorised user sets discussion privacy
  As a user who can set the privacy level
  I want to set the privacy level of my discussion to either public or private
  So I can choose who can see the discussion

  Scenario: Authorised user sets privacy
    Given I am logged in
    And I am a member of a group
    When I create a private discussion
    Then I should see that the discussion is set to private

  @javascript
  Scenario: Authorised user changes privacy
    Given I am logged in
    And I am a member of a group
    When I create a private discussion
    And I change the discussion privacy to public
    Then I should see that the discussion is set to public

  @javascript
  Scenario: User views authorised discussions
    Given I am logged in
    When I visit a public group
    Then I should see public discussions
    And I should not see private discussions

    When I visit a private group
    Then I should see public discussions
    And I should not see private discussions

  @javascript
  Scenario: Visitor views authorised discussions
    Given I am not logged in
    When I visit a public group
    Then I should see public discussions
    And I should not see private discussions

    When I visit a private group
    Then I should see public discussions
    And I should not see private discussions
