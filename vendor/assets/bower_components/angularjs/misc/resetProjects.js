var Q = require('q');
var https = require('https');

deleteAllProjects().
  then(createSampleProjects).
  then(function(){
    console.log('DONE');
  });


///////////////////////////////////////////////////////////////


function deleteAllProjects() {
  return request('DELETE');
}

function createSampleProjects() {
  return Q.all([
    createProject('AngularJS', 'http://angularjs.org', 'HTML enhanced for web apps!'),
    createProject('jQuery', 'http://jquery.com/', 'Write less, do more.'),
    createProject('Backbone', 'http://documentcloud.github.com/backbone/', 'Models for your apps.'),
    createProject('SproutCore', 'http://sproutcore.com/', 'Innovative web-apps.'),
    createProject('Sammy', 'http://sammyjs.org/', 'Small with class.'),
    createProject('Spine', 'http://spinejs.com/', 'Awesome MVC Apps.'),
    createProject('Cappucino', 'http://cappuccino.org/', 'Objective-J.'),
    createProject('Knockout', 'http://knockoutjs.com/', 'MVVM pattern.'),
    createProject('GWT', 'https://developers.google.com/web-toolkit/', 'JS in Java.'),
    createProject('Ember', 'http://emberjs.com/', 'Ambitious web apps.'),
    createProject('Batman', 'http://batmanjs.org/', 'Quick and beautiful.')
  ]);

  function createProject(name, site, description) {
    return request('POST', {
      name: name,
      site: site,
      description: description
    });
  }
}

function request(method, data) {
  var d = Q.defer();

  var options = {
    host: 'angularjs-projects.firebaseio.com',
    port: 443,
    path: '/.json',
    method: method || 'GET',
    headers: {
      'Content-Type': 'application/json'
    }
  };

  console.log(options.method, options.path);

  var req = https.request(options, function(res) {
    var body = [];
    res.setEncoding('utf8');
    res.on('data', function (chunk) {
      body.push(chunk);
    });
    res.on('end', function() {
      if (res.statusCode == 200) {
        d.resolve(JSON.parse(body.join('')));
      } else {
        console.log(body.join(''));
      }
    });
  });

  data && req.write(JSON.stringify(data));
  req.end();

  return d.promise;
}
