Feature: Loomio admin views group requests
  As a Loomio super-admin
  So that I can moderate the growth of the Loomio userbase
  I want to be able to see the state of different group requests

  Background:
    Given I am a Loomio super-admin
    And I am logged in
    And there are many group requests
    When I visit the Group Requests page on the admin panel

  Scenario: Loomio admin views verified group requests
    Then I should only see the verified group requests

  Scenario: Loomio admin views unverified group requests
    When I click to see unverified group requests
    Then I should only see the unverified group requests

  Scenario: Loomio admin views approved group requests
    When I click to see approved group requests
    Then I should only see the approved group requests

  Scenario: Loomio admin views accepted group requests
    When I click to see accepted group requests
    Then I should only see the accepted group requests
