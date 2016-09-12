BPlusTree = require('bplus-tree');

var tree = new BPlusTree(32);
var n;

for(i = 0; i < 10000; i++) {
  var key = Math.floor(100000*Math.random());
  tree.insert(key, "number #" + i);
  if (i == 5000) n = key;
}

tree.inspect();

if(n) console.log(n + ' = ' + tree.search(n));

tree.range(2145, 2777, function(key, value) {
  console.log(key + " = " + value);
});
