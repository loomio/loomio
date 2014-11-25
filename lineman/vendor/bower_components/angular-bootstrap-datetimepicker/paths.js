/* jshint node:true */

var bower = [
  'bower_components/jquery/dist/jquery.js',
  'bower_components/moment/moment.js',
  'bower_components/moment/locale/*.js',
  'bower_components/bootstrap/dist/js/bootstrap.js',
  'bower_components/angular/angular.js',
  'bower_components/angular-mocks/angular-mocks.js'
];
var sourceFiles = ['src/**/*.js'];
var testFiles = ['test/**/*.js'];
var miscFiles = ['karma.conf.js', 'demo/**/*.js'];
var bumpFiles = ['package.json', 'bower.json', 'README.md', 'src/js/*.js', 'src/css/*.css'];

module.exports = {
  all: bower.concat(sourceFiles).concat(testFiles).concat(miscFiles),
  app: sourceFiles,
  bump: bumpFiles,
  lint: ['gulpfile.js'].concat(sourceFiles).concat(testFiles).concat(miscFiles),
  test: testFiles
};
