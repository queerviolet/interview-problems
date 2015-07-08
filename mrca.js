#!/usr/bin/env node

// Given a binary tree and two node ids, find their first common ancestor.

"use strict";

var assert = require('assert');

/*     a
    b     c
   d e   f g
   
   mrca(a, b, c) -> a
   mrca(g, g, g) -> g
   mrca(a, d, e) -> b
   mrca(a, d, c) -> a
   mrca(d, a, f) -> undefined */

var tree = {
  value: 'a',
  left: {
    value: 'b',
    left: {value: 'd'},
    right: {value: 'e'},
  },
  right: {
    value: 'c',
    left: {value: 'f'},
    right: {value: 'g'},
  },
};

var a = tree, b = tree.left, c = tree.right,
    d = tree.left.left, e = tree.left.right,
    f = tree.right.left, g = tree.right.right;

function examples() {
  find(a, {e: e, a: a, f: f}, console.log.bind(console));
  console.log('--- mrca(a, b, c) ---');
  console.log(mrca(a, b, c)); assert.strictEqual(mrca(a, b, c), a);
  console.log('--- mrca(g, g, g) ---');
  console.log(mrca(g, g, g)); assert.strictEqual(mrca(g, g, g), g);
  console.log('--- mrca(a, d, e) ---');
  console.log(mrca(a, d, e)); assert.strictEqual(mrca(a, d, e), b);
  console.log('--- mrca(a, d, c) ---');
  console.log(mrca(a, d, c)); assert.strictEqual(mrca(a, d, c), a);
}

// 3. Assumptions
//   - node ids are just pointers to nodes.
//   - no parent pointers
//   - not a binary search tree


// -- Notes --
//
// Goal: I think I can do this traversing the tree exactly once.
//
// Note: Our two nodes are named leda and castor, arbitrarily.
//
// Observations:
//
// 1. If I am standing on a node and I find Leda to my left and Castor
// to my right, then I am standing at the MRCA of Leda and Castor.
//
// 2. We can describe the position of every node in a binary tree by
// listing the path of nodes you visit to find it from the root. Call
// this the node's path. I think it'll be easier to handle the edge case
// where leda === castor if paths include their terminal nodes. The path
// for the root above is [a]; the path to node e above is [b, e].
//
// 3. As a generalization of (1), the MRCA of a family of nodes is (by
// definition) the node whose path is the common prefix of the paths of
// all nodes in the family.
//
// Algorithm:
//
// typedef {left: node, right: node, value: object} node
//
// function mrca(root: node, leda: node, castor: node) -> node
//   paths = find(root, [leda, castor])
//   return undefined if len(paths) is not 2
//   ancestor = root
//   for i from 0 to Infinity:
//     current = None
//     for path in paths:
//       return ancestor if len(path) <= i
//       current = current || path[i]
//       return ancestor if current is not path[i]

// mrca(root: node, leda: node, castor: node, ...:node) -> Node
//
// Take a root and any number of tree nodes under the root, and returns
// their most recent (deepest) common ancestor.
//
// Nodes are considered ancestors of themselves, so the returned node may
// be in the argument set.
//
// This makes one search through the tree and one scan of the returned paths,
// so it's O(n).
//
// A better algorithm could do this in a single pass, by performing the path
// scan during find()'s stack unroll.
function mrca(root, leda, castor) {
  // Note that we actually accept an arbitrary number of nodes.
  var family = Array.prototype.slice.call(arguments, 1);
  var paths = find(root, family);
  if (paths.length != family.length) return undefined;

  var ancestor = root;
  for (var i = 0; true; ++i) {
    var current = null;
    var j = paths.length; while (--j >= 0) {
      var path = paths[j];
      if (path.length <= i) return ancestor;
      current = current || path[i];
      if (current !== path[i]) return ancestor;
    }
    ancestor = current;
  }
  // infinite loop is guaranteed to terminate at line 115, given
  // arrays of finite length.
}

// function find(haystack: node, needles: []node) -> [][]node
//
// Returns an array of paths [node, node, node...] leading from
// haystack to each node in needles. Paths include the needles
// we're looking for.
function find(haystack, needles, paths, currentPath) {
  if (!haystack) return paths; // End of tree, return what we have.
  currentPath = currentPath || [];
  paths = paths || new Array(needles.length);

  currentPath.push(haystack);

  var numFound = 0;
  var i = needles.length; while (--i >= 0) {
    if (!needles[i]) {
      ++numFound;
      continue;
    }
    if (haystack === needles[i]) {
      paths[i] = currentPath.slice();
      needles[i] = null;
    }
  }

  if (numFound !== needles.length) {
    find(haystack.left, needles, paths, currentPath);
    find(haystack.right, needles, paths, currentPath);
  }

  currentPath.pop();
  return paths;
}

module.exports = {
  tree: tree,
  a: a, b: b, c: c, d: d, e: e, f: f, g: g,
  find: find,
  mrca: mrca,
};

examples();
