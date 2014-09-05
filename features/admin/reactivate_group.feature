Feature: Unarchive Group

  As a Loomio admin
  So that I can meet the requests of users who ask to have their group unarchived
  I want to be able to unarchive archived groups from the admin panel

  @javascript
  Scenario: Loomio admin unarchives group
    Given there is a user in an archived group
    When their group is unarchived
    And they sign-in
    Then they should be able to view their group page
    And they should be able to view group discussions
    And any subgroups should be unarchived
