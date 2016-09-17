(function() {
  var BPlusTree = {
    make: function(fanout) {
      return {
        fanout: fanout,
        nodes: [],
        cohorts: [],
        root: 0
      };
    },

    // ------------------------
    // algorithm entry points
    // ------------------------

    find: function(tree, key, callback) {
      return {
        tree: tree,
        key: key,
        callback: callback,
        action: _find__start };
    },

    insert: function(tree, key, value, callback) {
      return {
        tree: tree,
        key: key,
        value: value,
        callback: callback,
        action: _insert__start };
    },

    remove: function(tree, key, callback) {
      return {
        tree: tree,
        key: key,
        callback: callback,
        action: _remove__start };
    },

    // ------------------------
    // state machine management
    // ------------------------

    next: function(state) {
      if (state.action) {
        if (!state.action(state)) {
          state.action = null;
        } else {
          return true;
        }
      }

      return false;
    }
  };

  // ------------------------------
  // "find" algorithm state machine
  // ------------------------------

  function _find__start(state) {
    if(state.tree.nodes.length > 0) {
      state.current = state.tree.root;
      state.callback('node:highlight', state.current);
      state.action = _binarySearch__start;
      state.afterSearch = _find__afterSearch;
    } else {
      return false;
    }

    return true;
  }

  function _find__afterSearch(state) {
    if (state.found === null) {
      state.callback('fail', "not found");
      return false;
    } else {
      var node = state.tree.nodes[state.current];
      var value = node.children[state.found].value;

      if (node.leaf) {
        state.callback('success', "found " + value);
        return false;
      } else {
        state.current = value;
        state.callback('node:highlight', state.current);
        state.action = _binarySearch__start;
        state.afterSearch = _find__afterSearch;
      }

      return true;
    }
  }

  // --------------------------------------
  // "quick search" algorithm state machine
  // --------------------------------------

  function _quickSearch__start(state) {
    // suppress callbacks during the search
    var savedCallback = state.callback;
    var savedAfterSearch = state.afterSearch;

    state.callback = function() { };
    state.afterSearch = null;

    state.action = _binarySearch__start;

    while (BPlusTree.next(state));

    state.action = savedAfterSearch;
    state.callback = savedCallback;

    state.callback("search:found", state.current, state.found, state.lo);

    return true;
  }

  // --------------------------------
  // "insert" algorithm state machine
  // --------------------------------

  // 1. if there are no nodes in the tree, create a new leaf node at 0,
  //    with the given key and value as the sole children.
  // 2. otherwise:
  //    a. find the leaf node that should contain the value
  //    b. find the location inside the node to put the value
  //    c. if the node is too large, split it and add the new node to
  //       the parent
  //    d. if there is no parent, create a new root node
  //    e. if the parent is now too large, split it (recursively)
  function _insert__start(state) {
    if (state.tree.nodes.length < 1) {
      state.tree.nodes[0] = {
        leaf: true,
        index: 0,
        cohort: 0,
        children: [ { key: state.key, value: state.value } ]
      }
      state.tree.root = 0;
      state.tree.cohorts[0] = [ 0 ];

      state.callback('node:root', 0);
      return false;

    } else {
      state.current = state.tree.root;
      state.callback('node:highlight', state.current);
      state.action = _quickSearch__start;

      var root = state.tree.nodes[state.tree.root];
      if (root.leaf) {
        state.afterSearch = _insert__afterLeafSearch;
      } else {
        state.afterSearch = _insert__afterNodeSearch;
      }

      return true;
    }
  }

  function _insert__afterNodeSearch(state) {
    var node = state.tree.nodes[state.current];
    var value = node.children[state.found].value;
    var child = state.tree.nodes[value];

    state.current = value;
    state.action = _quickSearch__start;
    state.callback('node:highlight', state.current);

    if (child.leaf) {
      state.afterSearch = _insert__afterLeafSearch;
    } else {
      state.afterSearch = _insert__afterNodeSearch;
    }

    return true;
  }

  function _insert__afterLeafSearch(state) {
    // state.found will probably be null (unless there are duplicates),
    // indicating that the key was not found. This is expected. Instead,
    // state.lo will tell us where the new key ought to be inserted.

    var node = state.tree.nodes[state.current];
    var loKey = node.children[state.lo].key;

    // special case, when the key should go at the end of the list
    if (loKey < state.key) state.lo += 1;
    node.children.splice(state.lo, 0, { key: state.key, value: state.value });

    state.callback('node:insert', state.current, state.lo);

    if (node.children.length > state.tree.fanout) {
      state.action = _splitNode__start;
      return true;
    }

    return false;
  }

  // ---------------------------------------
  // "split node" algorithm state machine
  // ---------------------------------------

  function _splitNode__start(state) {
    var node = state.tree.nodes[state.current];
    state.splitAt = Math.floor(node.children.length / 2);
    state.callback('split:mid', state.current, state.splitAt);
    state.action = _splitNode__newNode;
    return true;
  }

  // split:
  // * twin gets the left half
  // * current node gets the right half
  function _splitNode__newNode(state) {
    var nodeIndex = state.current;
    var node = state.tree.nodes[nodeIndex];

    state.twin = state.tree.nodes.length;
    var twin = { leaf: node.leaf, parent: node.parent, cohort: node.cohort, index: state.twin };
    state.tree.nodes[state.twin] = twin;
    state.tree.cohorts[node.cohort].push(state.twin);

    twin.children = node.children.slice(0, state.splitAt);
    node.children = node.children.slice(state.splitAt);

    if (node.leaf) {
      // update the linked list
      twin.prev = node.prev;
      if (twin.prev) {
        var prev = state.tree.nodes[twin.prev];
        prev.next = state.twin;
      }
      twin.next = nodeIndex;
      node.prev = state.twin;
    } else {
      for(var i = 0; i < twin.children.length; i++) {
        var child = state.tree.nodes[twin.children[i].value];
        child.parent = state.twin;
      }
    }

    // key for twin is always the smallest key of the
    // right-half, since all of twin will be less than
    // what's in the current node.
    state.twinKey = smallestKey(state.tree, node);

    var proceed = true;

    if (node.parent) {
      var parent = state.tree.nodes[node.parent];
      for(var i = 0; i < parent.children.length; i++) {
        if (parent.children[i].value == nodeIndex) {
          parent.children.splice(i, 0, { key: state.twinKey, value: state.twin });
          break;
        }
      }

      if (parent.children.length > state.tree.fanout) {
        state.action = _splitNode__start;
        state.current = node.parent;
      } else {
        proceed = false;
      }
    } else {
      state.action = _splitNode__newRoot;
    }

    state.callback('split:nodes', state.twin, nodeIndex);
    return proceed;
  }

  function _splitNode__newRoot(state) {
    var node = state.tree.nodes[state.current];
    var twin = state.tree.nodes[state.twin];

    state.tree.root = state.tree.nodes.length;

    var root = {
      index: state.tree.root,
      cohort: node.cohort + 1,
      children: [ { key: state.twinKey, value: state.twin },
                  { key: null, value: state.current } ]
    };

    state.tree.nodes[state.tree.root] = root;
    state.tree.cohorts[root.cohort] = [ state.tree.root ];

    node.parent = state.tree.root;
    twin.parent = state.tree.root;

    state.callback('node:root', state.tree.root);

    return false;
  }

  // ---------------------------------------
  // "remove" algorithm state machine
  // ---------------------------------------

  // 1. descend the tree, looking for the node that contains the key
  // 2. if not found -- finish
  // 3. otherwise, remove the value from the node
  // 4. if node is more than half full -- finish
  // 5. if node + neighboring sibling is overfull -- finish
  // 6. otherwise, merge node + neighboring sibling
  // 7. repeat from 4 with parent node
  function _remove__start(state) {
    if (!state.tree.root) {
      return false;
    }

    state.current = state.tree.root;
    state.callback('node:highlight', state.current);
    state.action = _quickSearch__start;

    var root = state.tree.nodes[state.tree.root];
    if (root.leaf) {
      state.afterSearch = _remove__afterLeafSearch;
    } else {
      state.afterSearch = _remove__afterNodeSearch;
    }

    return true;
  }

  function _remove__afterNodeSearch(state) {
    var node = state.tree.nodes[state.current];
    var value = node.children[state.found].value;
    var child = state.tree.nodes[value];

    state.current = value;
    state.action = _quickSearch__start;
    state.callback('node:highlight', state.current);

    if (child.leaf) {
      state.afterSearch = _remove__afterLeafSearch;
    } else {
      state.afterSearch = _remove__afterNodeSearch;
    }

    return true;
  }

  function _remove__afterLeafSearch(state) {
    // state.found must be non-null. If it is null, then the key
    // was not found, and the operation finishes.

    if (state.found == null) {
      return false;
    }

    var node = state.tree.nodes[state.current];
    var at = state.found;

    state.callback('cell:highlight', state.current, at);

    state.action = _remove__removeCell;
    return true;
  }

  function _remove__removeCell(state) {
    var node = state.tree.nodes[state.current];
    node.children.splice(state.found, 1);
    state.callback('cell:remove', state.current, state.found);

    if (node.parent && node.children.length <= tree.fanout / 2) {
      var candidates = [];
      var parent = tree.nodes[node.parent];

      for(var i = 0; i < parent.children.length; i++) {
        if (parent.children[i].value == node.index) {
          if(i > 0) candidates.push(parent.children[i-1]);
          if(i+1 < parent.children.length) candidates.push(parent.children[i+1]);
          break;
        }
      }

      if (candidates.length > 0) {
        state.siblings = candidates;
        state.action = _remove__checkSiblings;
        return true;
      }
    } else if (!node.parent && node.children.length < 2) {
      // FIXME: decrease height by removing root node and making
      // it's sole child the new root.
    }

    return false;
  }

  function _remove__checkSiblings(state) {
    var candidateIndex = state.candidates.pop();
    var node = tree.nodes[state.current];
    var candidate = tree.nodes[candidateIndex];

    state.callback('merge:consider', candidateIndex);

    if (node.children.length + candidate.children.length <= tree.fanout) {
      state.action = _remove__mergeNodes;
      state.target = candidateIndex;
      return true

    } else if (state.candidates.length > 0) {
      state.action = _remove__checkSiblings;
      return true;

    } else {
      return false;
    }
  }

  function _remove__mergeNodes(state) {
    var target = tree.nodes[state.target];
    var current = tree.nodes[state.current];
    var parent = tree.nodes[target.parent];

    state.callback('node:cleanup', state.current);

    target.children += current.children;

    for(var i = 0; i < parent.children.length; i++) {
      if (parent.children[i].value == state.current) {
        state.found = i;
        break;
      }
    }

    state.current = target.parent;
    state.action = _remove__removeCell;

    state.callback('merge:nodes', state.target, state.current);

    return true;
  }

  // ---------------------------------------
  // "binary search" algorithm state machine
  // ---------------------------------------

  function _binarySearch__start(state) {
    var node = state.tree.nodes[state.current];
    var lo = 0;
    var hi = node.children.length - 1;
    state.callback('search:range', state.current, lo, hi);
    state.action = _binarySearch__mid;
    state.lo = lo;
    state.hi = hi;
    return true;
  }

  function _binarySearch__mid(state) {
    state.mid = state.lo + Math.floor((state.hi - state.lo) / 2);
    state.callback('search:mid', state.current, state.mid);
    state.action = _binarySearch__choose;
    return true;
  }

  /* works like this:
   *
   * 1. If the node is a leaf, and state.mid == key, we're done, having
   *    found the child we're looking for.
   * 2. If lo == hi, then our search has narrowed as far as it can go.
   *    a. If the node is a leaf, the search fails, because nothing
   *       was found.
   *    b. If the node is NOT a leaf, then our desired child is at this
   *       index, and lo (hi) is what we're looking for.
   * 3. If key < nodes[mid], repeat from 1 with hi=mid
   * 4. If key >= nodes[mid], repeat from 1 with lo=mid+1
   *
   * Consider these scenarios...
   *
   * [  15   40   72   99   --]
   * [aaaa bbbb cccc dddd eeee]
   *
   * Given non-leaf node (length=5) and a key of 37...
   * 1. lo = 0, hi = 4
   * 2. mid = 0 + (4 - 0)/2 = 2
   * 3. 37 < nodes[mid].key (72), so hi=mid
   * 4. lo = 0, hi = 2, mid = 1
   * 5. 37 < nodes[mid].key (40), so hi=mid
   * 6. lo = 0, hi = 1, mid = 0
   * 7. 37 > nodes[mid].key (15), so lo=mid+1
   * 8. lo = 1, hi = 1, mid = 1
   * 9. lo == hi, so search terminates, returning 1 (key=40)
   *
   * Given non-leaf node (length=5) and a key of 105...
   * 1. lo = 0, hi = 4
   * 2. mid = 0 + (4 - 0)/2 = 2
   * 3. 105 > nodes[mid].key (72), so lo=mid+1
   * 4. lo=3, hi=4, mid=3
   * 5. 105 > nodes[mid].key (99), so lo=mid+1
   * 6. lo=4, hi=4, mid=4
   * 7. lo == hi, so search terminates, returning 4 (key=nil)
   *
   * Given non-leaf node (length=5) and a key of 15...
   * 1. lo = 0, hi = 4
   * 2. mid = 0 + (4 - 0)/2 = 2
   * 3. 15 < nodes[mid].key (72), so hi=mid
   * 4. lo=0, hi=2, mid=1
   * 5. 15 < nodes[mid].key (40), so hi=mid
   * 6. lo=0, hi=1, mid=0
   * 7. 15 >= nodes[mid].key (15), so lo=mid+1
   * 8. lo=1, hi=1, mid=1
   * 9. lo == hi, so search terminates, returning 1 (key=40)
   */
  function _binarySearch__choose(state) {
    var node = state.tree.nodes[state.current];

    if (node.leaf && state.key == node.children[state.mid].key) {
      state.found = state.mid;
      state.callback('search:found', state.current, state.found, state.mid);
      state.action = state.afterSearch;

    } else if (state.lo == state.hi) {
      if (node.leaf) {
        state.found = null;
      } else {
        state.found = state.lo;
      }
      state.callback('search:found', state.current, state.found, state.lo)
      state.action = state.afterSearch;

    } else {
      if (state.key < node.children[state.mid].key) {
        state.hi = state.mid;
      } else {
        state.lo = state.mid+1;
      }

      state.callback('search:range', state.current, state.lo, state.hi);
      state.action = _binarySearch__mid;
    }

    return true;
  }

  // ---------------------------------------
  // utility functions
  // ---------------------------------------

  function smallestKey(tree, node) {
    if (node.leaf) {
      return node.children[0].key;
    } else {
      var childIndex = node.children[0].value;
      var child = tree.nodes[childIndex];

      return smallestKey(tree, child);
    }
  }

  var exports = {
    BPlusTree: BPlusTree
  };

  if (typeof module !== 'undefined' && typeof module.exports !== 'undefined')
    module.exports = exports;
  else
    window.exports = exports;
})();
