(function() {
  function binarySearch(list, target, lo, hi) {
    var mid = lo + Math.floor((hi - lo) / 2);

    if (target < list[mid]) {
      if (lo == hi) return lo;
      return binarySearch(list, target, lo, mid);
    }

    if (hi == mid) return mid+1;
    return binarySearch(list, target, mid+1, hi);
  }

  var BPlusTreeLeafNode = (function() {
    function BPlusTreeLeafNode(fanout) {
      this.fanout = fanout;
      this.parent = null;
      this.keys = [];
      this.values = [];
      this.next = null;
      this.prev = null;
    }

    BPlusTreeLeafNode.prototype.findNode = function(key) {
      return this;
    }

    BPlusTreeLeafNode.prototype.find = function(key) {
      // n-1 because binarySearch finds location at key+1
      var index = binarySearch(this.keys, key, 0, this.keys.length-1) - 1;
      if (index >= 0 && this.keys[index] === key)
        return this.values[index];
      return null;
    }

    BPlusTreeLeafNode.prototype.smallestKey = function() {
      return this.keys[0];
    }

    BPlusTreeLeafNode.prototype.insert = function(key, value) {
      var index = binarySearch(this.keys, key, 0, this.keys.length-1);
      this.keys.splice(index, 0, key);
      this.values.splice(index, 0, value);

      if (this.keys.length > this.fanout) {
        var mid = this.keys.length / 2;
        var twin = new BPlusTreeLeafNode(this.fanout);
        twin.keys = this.keys.slice(0, mid);
        twin.values = this.values.slice(0, mid);
        this.keys = this.keys.slice(mid);
        this.values = this.values.slice(mid);

        twin.prev = this.prev;
        if (twin.prev) twin.prev.next = twin;
        twin.next = this;
        this.prev = twin;

        if (this.parent) {
          return this.parent.insertNode(this.keys[0], twin);
        } else {
          var parent = new BPlusTreeNode(this.fanout);
          parent.keys = [ this.keys[0] ];
          parent.children = [ twin, this ];
          this.parent = twin.parent = parent;
          return parent;
        }
      }

      return this;
    }

    BPlusTreeLeafNode.prototype.inspect = function(indent) {
      var i;

      if (this.prev) console.log(indent + "<< " + this.prev.keys[this.prev.keys.length-1]);
      for(i = 0; i < this.keys.length; i++) {
        console.log(indent + this.keys[i] + " = " + this.values[i]);
      }
      if (this.next) console.log(indent + ">> " + this.next.keys[0]);
    }

    return BPlusTreeLeafNode;
  })();

  var BPlusTreeNode = (function() {
    function BPlusTreeNode(fanout) {
      this.fanout = fanout;
      this.parent = null;
      this.keys = [];
      this.children = [];
    }

    BPlusTreeNode.prototype.findNode = function(key) {
      var index = binarySearch(this.keys, key, 0, this.keys.length-1);
      return this.children[index].findNode(key);
    }

    BPlusTreeNode.prototype.find = function(key) {
      var node = this.findNode(key);
      return node.find(key);
    }

    BPlusTreeNode.prototype.insert = function(key, value) {
      var index = binarySearch(this.keys, key, 0, this.keys.length-1);
      return this.children[index].insert(key, value);
    }

    BPlusTreeNode.prototype.smallestKey = function() {
      return this.children[0].smallestKey();
    }

    BPlusTreeNode.prototype.insertNode = function(key, node) {
      var index = binarySearch(this.keys, key, 0, this.keys.length-1);

      node.parent = this;
      this.keys.splice(index, 0, key);
      this.children.splice(index, 0, node);

      if (this.children.length > this.fanout) {
        var mid = this.keys.length / 2;
        var twin = new BPlusTreeNode(this.fanout);
        twin.keys = this.keys.slice(0, mid-1);
        twin.children = this.children.slice(0, mid);
        this.keys = this.keys.slice(mid);
        this.children = this.children.slice(mid);

        for(var i = 0; i < twin.children.length; i++) {
          twin.children[i].parent = twin;
        }

        if (this.parent) {
          return this.parent.insertNode(this.smallestKey(), twin);
        } else {
          var p = new BPlusTreeNode(this.fanout);
          p.keys = [ this.smallestKey() ];
          p.children = [ twin, this ];
          this.parent = twin.parent = p;
          return p;
        }
      }

      return this;
    }

    BPlusTreeNode.prototype.inspect = function(indent) {
      var i;

      for(i = 0; i < this.keys.length; i++) {
        console.log(indent + "< " + this.keys[i] + ":");
        this.children[i].inspect(indent + "  ");
      }

      console.log(indent + "else:");
      this.children[i].inspect(indent + "  ");
    }

    return BPlusTreeNode;
  })();

  var BPlusTree = (function() {
    function BPlusTree(fanout)
    {
      this.fanout = fanout;
      this.root = null;
    }

    BPlusTree.prototype.insert = function(key, value) {
      if (this.root === null) {
        this.root = new BPlusTreeLeafNode(this.fanout);
        this.root.keys[0] = key;
        this.root.values[0] = value;
      } else {
        var node = this.root.insert(key, value);
        if (node.parent === null) this.root = node;
      }
    }

    BPlusTree.prototype.search = function(key) {
      if (!this.root) return null;
      return this.root.find(key);
    }

    BPlusTree.prototype.range = function(from, to, callback) {
      if (!this.root) return;

      var node = this.root.findNode(from);
      var index = binarySearch(node.keys, from, 0, node.keys.length-1)-1;
      if (index < 0 || node.keys[index] < from) index += 1;

      while(node) {
        if (index >= node.keys.length) {
          node = node.next;
          index = 0;
        }

        if (node.keys[index] > to) break;

        callback(node.keys[index], node.values[index]);
        index += 1;
      }
    }

    BPlusTree.prototype.inspect = function() {
      console.log("BPlusTree(" + this.fanout + "):");
      if (this.root) {
        this.root.inspect("  ");
      } else {
        console.log("  [[empty]]");
      }
    }

    BPlusTree.prototype.remove = function(key) {
    }

    return BPlusTree;
  })();

  if (typeof module !== 'undefined' && typeof module.exports !== 'undefined')
    module.exports = BPlusTree;
  else
    window.exports = BPlusTree;
})();
