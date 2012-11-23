Feature: User requests to create a group on Loomio
  As a prospective Loomio User
  So that I can start using Loomio with a group I belong to in real life
  I want to be able to request to add my group to Loomio

  Scenario: User submits Request New Group Form
    When I visit the Request New Group page
    And I fill in and submit the Request New Group Form
    Then a new Loomio group request should be created
    And I should be told that my request will be reviewed shortly

  Scenario: User submits an incorrect Request New Group Form
    When I visit the Request New Group page
    And I fill in and submit the Request New Group Form incorrectly
    Then a new Loomio group request should not be created
    And I should still see the Group Request Form
