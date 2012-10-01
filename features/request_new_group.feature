Feature: User requests to create a group on Loomio
  As a prospective Loomio User
  So that I can start using Loomio with a group I belong to in real life
  I want to be able to request to add my group to Loomio

  #Scenario: User wants to know how they can use Loomio
    #When I visit the Join Loomio page
    #Then I should see that I need to pitch Loomio to my group and get their approval

  Scenario: User views Request New Group Form
    When I visit the Request New Group page
    Then I should see the Request New Group Form

  Scenario: User submits Request New Group Form
    #Given I have discussed using Loomio with my group
    When I visit the Request New Group page
    #And I click “I have support from my group”
    And I fill in and submit the Request New Group Form
    Then a new Loomio group request should be created
    And I should be told that my request will be reviewed shortly

  Scenario: User submits an incorrect Request New Group Form
    When I visit the Request New Group page
    And I fill in and submit the Request New Group Form incorrectly
    Then a new Loomio group request should not be created
    And I should be told what to change in the form
