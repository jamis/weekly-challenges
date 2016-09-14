BPlusTree = require('illustrated-bplus-tree').BPlusTree;

var tree = BPlusTree.make(4);

function insert(tree, key, value) {
  var state = BPlusTree.insert(tree, key, value,
    function(action) {
      console.log(action, arguments);
    });

  while (BPlusTree.next(state));
  console.log("----------");
  console.log("root =", tree.root);
  for(var i = 0; i < tree.nodes.length; i++) {
    console.log(i, tree.nodes[i]);
  }
}

insert(tree, 250, "two hundred fifty");
insert(tree, 120, "one hundred twenty");
insert(tree, 370, "three hundred seventy");
insert(tree, 50, "fifty");
insert(tree, 450, "four hundred fifty");
insert(tree, 310, "three hundred ten");
insert(tree, 410, "four hundred ten");
insert(tree, 185, "one hundred eighty five");
insert(tree, 3, "three");
insert(tree, 911, "nine hundred eleven");
insert(tree, 747, "seven hundred forty seven");
insert(tree, 293, "two hundred ninety three");
insert(tree, 18, "eighteen");
insert(tree, 888, "eight hundred eighty eight");
insert(tree, 973, "nine hundred seventy three");
insert(tree, 602, "six hundred two");
insert(tree, 554, "five hundred fifty four");
insert(tree, 179, "one hundred seventy nine");
insert(tree, 96, "ninety six");

var state = BPlusTree.find(tree, 120,
  function(action) {
    console.log(action, arguments);
  });
while (BPlusTree.next(state));
