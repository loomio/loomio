Feature: Loomio provides proper metadata for social websites
  So that I can link Loomio pages and engage more users
  I want pages like FB to preview data relevant to the page linked

  Scenario: Public group has social metadata specific to the group
    Given there is a discussion in a public group
    When I visit the group page
    Then social meta-data about the group should be present

  Scenario: Public discussion has social metadata specific to the discussion
    Given there is a discussion in a public group
    When I visit the discussion page
    Then social meta-data about the discussion should be present

  Scenario: Private group has generic social metadata
    Given I am logged in
    And there is a discussion in a private group
    When I visit the group page
    Then social meta-data about the group should not be present

  Scenario: Private discussion has generic social metadata
    Given I am logged in
    And there is a discussion in a private group
    When I visit the discussion page
    Then social meta-data about the discussion should not be present

  Scenario: Loomio pages have facebook admin id metadata
    Given there is a discussion in a private group
    When I visit the discussion page
    Then facebook meta-data should be present
