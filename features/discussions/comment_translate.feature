Feature: Translate a comment into a different language
  To allow a user to read a discussion regardless of his native language
  A user must be able to translate comments in a different language

  @javascript
  Scenario: Comment in a different language
    Given I am logged in
    And I speak French
    And I am a member of a group
    And there is a discussion in the group
    And there is a comment in the discussion
    And the translator exists and can translate
    And the comment is written by an English speaker
    When I visit the discussion page
    Then I should see a link to translate the comment
    
  @javascript
  Scenario: Comment in the same language
    Given I am logged in
    And I speak English
    And I am a member of a group
    And there is a discussion in the group
    And there is a comment in the discussion
    And the comment is written by an English speaker
    When I visit the discussion page
    Then I should not see a link to translate the comment

  @javascript
  Scenario: Clicking translate link performs successful translation
   	Given I am logged in
    And I speak French
    And I am a member of a group
    And there is a discussion in the group
    And there is a comment in the discussion
    And the comment is written by an English speaker
    And the translator exists and can translate
    When I visit the discussion page
 	And I click on the translate link
  	And I wait 5 seconds
  	Then the translation should appear 
  
  @javascript
  Scenario: Clicking translate link shows error message for failed translation
   	Given I am logged in
    And I speak French
    And I am a member of a group
    And there is a discussion in the group
    And there is a comment in the discussion
    And the comment is written by an English speaker
    And the translator exists and cannot translate
    When I visit the discussion page
 	And I click on the translate link
  	And I wait 5 seconds
  	Then a failure to translate message should appear   