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
