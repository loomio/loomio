Feature: User requests to create a group on Loomio
  As a prospective Loomio User
  So that I can start using Loomio with a group I belong to in real life
  I want to be able to request to add my group to Loomio

  #Scenario: User wants to know how they can use Loomio
    #When I visit the Join Loomio page
    #Then I should see that I need to pitch Loomio to my group and get their approval

  Scenario: User requests to bring their group onto Loomio
    Given I have discussed using Loomio with my group
    When I visit the Join Loomio page
    #And I click “I have support from my group”
    Then I should see the Loomio Application Form
    When I fill in and submit Loomio Application Form
    Then a new Loomio group request should be created
    And I should be told that my request will be reviewed shortly
