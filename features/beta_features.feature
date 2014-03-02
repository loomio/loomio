Feature: beta_features

Scenario: User enables a beta Feature
  Given I am logged in
  When I load the beta features settings page
  And enable the beta feature
  Then the beta features should be enabled
