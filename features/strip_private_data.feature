Feature: Strip Private Data
  As a an admin
  So that I can take production data and make it safe for distribution
  I want to be able to delete all private data from a database

  Scenario: a private group + strip private data
    Given there is a private group with members, discussions, comments, and motions
    When I strip private data from the database
    Then the database should be empty apart from users
    And user email and passwords should be foo'd

  Scenario: a public group + strip private data
    Given there is a public group with members, discussions, comments, and motions
    When I strip private data from the database
    Then the group should not be deleted
    And no data associated with that group should be deleted

  Scenario: archived group + strip private data
    Given there is an archived group
    When I strip private data from the database
    Then the database should be empty apart from users

### these are to be impimented when discussion level privacy is live: ###

  Scenario: a public group with a private discussion + strip private data
    Given there is a public group with a private discussion
    When I strip private data from the database
    Then the private discussion should be destroyed

  Scenario: a private group with a public discussion + strip private data
    Given there is a private group with a public discussion
    When I strip private data from the database
    Then the database should be empty apart from users
