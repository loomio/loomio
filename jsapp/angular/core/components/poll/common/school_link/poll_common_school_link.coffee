angular.module('loomioApp').directive 'pollCommonSchoolLink', ->
  scope: {translation: '@', href: '@'}
  templateUrl: 'generated/components/poll/common/school_link/poll_common_school_link.html'
