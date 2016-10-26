angular.module('loomioApp').directive 'introductionCarousel', ->
  scope: false
  restrict: 'E'
  templateUrl: 'generated/components/introduction_carousel/introduction_carousel.html'
  replace: true
  controller: ($scope, $animate, $timeout) ->

    $scope.dismissed = false

    $scope.show = ->
      !$scope.dismissed

    $scope.dismiss = ->
      $scope.dismissed = true

    $scope.slides = [
      {image: 'img/gather.png', title: 'Gather', description: "All your Loomio activity happens with a group. Check who's here and invite people if anyone is missing."},
      {image: 'img/discuss.png', title: 'Discuss', description: "Start a thread to have a discussion with your group members. Keep each thread focussed on one topic."},
      {image: 'img/propose.png', title: 'Propose', description: "Use a proposal to move a thread towards a conclusion: everyone is asked to have their say on a specific course of action."},
      {image: 'img/act.png', title: 'Decide & Act', description: "When the proposal closes you'll get a visual summary of everyone's input. Notify everyone of the outcome so the next steps are clear."}
    ]

    $scope.currentIndex = 0

    $scope.setCurrentSlideIndex = (index) ->
      $scope.currentIndex = index

    $scope.isCurrentSlideIndex = (index) ->
      $scope.currentIndex == index

    $scope.prevSlide = ->
      $scope.currentIndex = if $scope.currentIndex < $scope.slides.length - 1 then ++$scope.currentIndex else 0

    $scope.nextSlide = ->
      $scope.currentIndex = if $scope.currentIndex > 0 then --$scope.currentIndex else $scope.slides.length - 1
