Feature: Group level beta features
  In order to selectively enable features for a group
  As a system admin

  Scenario: Enable iframe on discussion beta feature for group
    Given there is a beta feature "iframe_on_discussion"
    When I enable the beta feature "iframe_on_discussion"
    Then the group should have "iframe_on_discussion" beta feature
