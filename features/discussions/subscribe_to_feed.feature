Feature: Subscribe to feed
  As a visitor to a public discussion
  To more easily keep up with discussion updates
  I should be able to subscribe to a feed of activity within the discussion

  Scenario: Subscribe to feed link is present for public discussion
  	Given there is a public discussion in a public group
    When I visit the discussion page
    Then I should see a subscribe to feed link
    
  Scenario: Subscribe to feed link is not present for private discussion
  	Given there is a discussion in a private group
  	When I visit the discussion page
  	Then I should not see a subscribe to feed link
  	
  Scenario: Clicking the Subscribe to feed link returns an xml feed
    Given there is a public group with a discussion with a comment
    When I visit the discussion subscribe to feed link
    Then I should see a discussion xml feed
    And the xml feed should have the comment
