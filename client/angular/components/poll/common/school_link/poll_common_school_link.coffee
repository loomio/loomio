angular.module('loomioApp').directive 'pollCommonSchoolLink', ->
  scope: {translation: '@', href: '@'}
  template: require('./poll_common_school_link.haml')
