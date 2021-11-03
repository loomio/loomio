
// here is a test script I used to understand if I got the sorting right
// https://rawgit.com/techfort/LokiJS/master/examples/sandbox/LokiSandbox.htm
// testdb = new loki('test.db');
// events = testdb.addCollection('events', {indices: ['key']});
//
// input = [
//   {key: '001'},
//   {key: '001-001'},
//   {key: '001-002'},
//   {key: '002'},
//   {key: '002-001'},
// ]
// events.insert(input)
//
// keys = events.chain().simplesort('key',  { useJavascriptSorting: true }).data().map( o => o.key)
// logText('result')
// logObject(keys)
// logText('desired result')
// logObject(input.map( o => o.key))

import loki from 'lokijs'

var cmp = function(a, b) {
  if (a == b) return 0;
  if (a < b) return -1;
  return 1;
}

// attach aeq onto loki.Comparators
loki.Comparators.aeq = function(a, b) {
  return cmp(a, b) === 0;
}

// attach lt onto loki.Comparators
loki.Comparators.lt = function(a, b, eq) {
	var result = cmp(a, b);
	switch(result) {
      case -1: return true;
      case 0: return eq;
      case 1: return false;
    }
}

// attach gt onto loki.Comparators
loki.Comparators.gt = function(a, b, eq) {
  var result = cmp(a, b);
	switch(result) {
      case -1: return false;
      case 0: return eq;
      case 1: return true;
    }
}

export default loki
