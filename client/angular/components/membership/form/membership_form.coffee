angular.module('loomioApp').directive 'membershipForm', ->
  scope: {membership: '='}
  template: require('./membership_form.haml')
