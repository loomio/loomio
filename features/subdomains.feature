Feature: Subdomains

  Background:
    Given there is a group with a subdomain
    And I have a user account

  Scenario: Visiting group subdomain loads group page
    When I visit the site with that subdomain
    Then I should see the group page for that group

  Scenario: Logging in from subdomain group page keeps the subdomain
    When I visit the site with that subdomain
    And I click the log in button
    Then I should see the subdomain login page
    When I login
    Then I should see the subdomain group page

  Scenario: Viewing discussion from group page preserves subdomain
    When I visit the site with that subdomain
    And I view a discussion
    Then I should see the discussion from that subdomain

  Scenario: Visiting group with subdomain from root takes me to the subdomain group page
    Given I am on the root dashboard
    When I visit a subdomained group
    Then I should be on the subdomain

  Scenario: Visiting group with no subdomain from subdomain takes me to root group page
    Given I am on the subdomain group page
    When I visit a non subdomain group page
    Then I should be on the root group page

  Scenario: Visiting subgroup of group with domain takes me to subdomained group page
    Given there is a subgroup of a group with a domain
    When I visit the group from the dashboard
    Then I should be on the subdomain looking at the subgroup


