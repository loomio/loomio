Feature: Post a comment in a discussion
  To allow users to share their opinions
  A user must be able to post comments in a discussion

  Background:
    Given I am logged in
    And I am a member of a group
    And there is a discussion in the group

  @javascript
  Scenario: User posts comment
    When I visit the discussion page
    And I write and submit a comment
    Then a comment should be added to the discussion
    And the comment should be displayed left-to-right

  @javascript
  Scenario: Discussion activity clears when user posts comment
    When I visit the discussion page
    And I write and submit a comment
    And I visit the group page
    Then I should not see new activity for the discussion

  @javascript
  Scenario: User enables markdown and posts a comment
    Given I don't prefer markdown
    When I visit the discussion page
    #And I enable comment markdown
    And I write and submit a comment
    Then a comment should be added to the discussion
    #And the comment should format markdown characters
    #And the comment should autolink links
    #And the comment should include appropriate new lines
    #And comment markdown should now be on by default

  #@javascript
  #Scenario: User disable markdown and posts a comment
    #Given I am logged in
    #And I am a member of a group
    #And there is a discussion in the group
    #And I prefer markdown
    #When I visit the discussion page
    ##And I disable comment markdown
    #And I write and submit a comment
    #Then a comment should be added to the discussion
    #And the comment should not format markdown characters
    #And the comment should autolink links
    #And the comment should include appropriate new lines
    ##And comment markdown should now be off by default

  Scenario: Comments have permalinks
    Given the discussion has a comment
    When I visit the discussion page
    Then there should be an anchor for the comment
    And I should see a permalink to the anchor for that comment

  Scenario: Hebrew user post RTL formatted comments
    Given my selected locale is "he"
    When I visit the discussion page
    And I write and submit a comment
    Then the comment should be displayed right-to-left

