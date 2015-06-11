<<-DOC

Given an array, construct a binary tree assuming that the children of A[i]
are stored at A[2*i + 1] (left child) and A[2*i + 2] (right child)

Function signature:

    build_binary_tree(ary, start_index=0) -> BinaryTree

Examples:
  build_binary_tree([]) -> nil
  build_binary_tree([1, 2, 3, 4, 5, 6, 7]) ->
         1
      2     3
     4 5   6 7

  build_binary_tree([1, nil, 3, 4, 5, 6, 7]) ->
         1
            3
           6 7

You can use a hash of {value: object, left: tree, right: tree} to
represent a tree.

DOC

require 'minitest/autorun'

describe :build_binary_tree do
  ary = [5, 19, -5, 10, nil, 7, nil, 8, 5]
  tree = {
    value: 5,
    left: {
      value: 19,
      left: {
        value: 10,
        left: {value: 8, left: nil, right: nil},
        right: {value: 5, left: nil, right: nil},
      },
      right: nil,
    },
    right: {
      value: -5,
      left: {value: 7, left: nil, right: nil},
      right: nil
    },
  }

  it 'should work on this weird array' do
    build_binary_tree(ary).must_equal(tree)
  end

  it 'should be possible to implement iteratively' do
    iterative_binary_tree(ary).must_equal(tree)
  end
end

#### Recursive approach
#
# This function is a little bit less terse than it could be
# to make it easier to compare to the iterative version below.
def build_binary_tree(ary, index=0)
  return nil if ary[index] == nil
  node = {value: ary[index]}
  node[:left] = build_binary_tree(ary, 2 * index + 1)
  node[:right] = build_binary_tree(ary, 2 * index + 2)
  return node
end


#### Iterative approach
#
# "What if the tree is too deep to use a recursive approach?"
#
# Well, then your life is a bit harder.
#
# This is naïve approach to converting the recursive function above
# into an iterative function. It's not naïve in the sense that it's
# very simple and readable, but rather in that it's a very mechanical
# c
#
# Here's how we'll convert our function:
#
# 1. We'll put all the local variables we use into a single
# data structure (called a stack frame). There are three:
#
#     index, node, ary
#
# But ary never changes between recursive calls, so we don't need
# to keep track of it in our stack frame.
#
# Our stack frame also needs to keep track of where we are in the
# method body call:
#
#   1. have we just entered it? (lines 63-64)
#   2. are we waiting for the left recursive call (line 65)?
#   3. are we waiting on the right recursive call (line 66)?
#
# We'll call these states nil, :left, and :right.
#
# We'll just use a hash of {index, node, state} to store our stack frame.
#
# The equivalent of making a method call is constructing a new StackFrame
# with the arguments we want and pushing it onto a stack.
#
# The equivalent of returning from a method call is putting our return
# value into ret and popping the stack.
def iterative_binary_tree(ary)
  # Start by pushing (index=0) onto the stack.
  stack = [{index: 0}]

  # Ret is where return values go (the return register)
  ret = nil

  # Execute the top most stack frame until the stack is cleared.
  until stack.empty?
    frame = stack.last
    index = frame[:index]
    case frame[:state]
    when nil
      if ary[index] == nil             # build_binary_tree:63
        ret = nil; stack.pop()         # build_binary_tree:63 (return nil)
      else
        frame[:node] = {value: ary[frame[:index]]} # build_binary_tree:64
        frame[:state] = :left
        call = {index: index * 2 + 1}
        stack.push(call)               # build_binary_tree:65 (recursive call)
      end
    
    when :left
      frame[:node][:left] = ret # build_binary_tree:65 (assignment)
      frame[:state] = :right
      call = {index: frame[:index] * 2 + 2} 
      stack.push(call)                 # build_binary_tree:66 (recursive call)

    when :right
      frame[:node][:right] = ret       # build_binary_tree:66 (assignment)
      ret = frame[:node]; stack.pop()  # build_binary_tree:67 (return node)
    end
  end

  # Return whatever was returned by the topmost stack frame.
  return ret
end



# We'll use JSON.pretty_generate to get output that reasonably looks
# vaguely tree-ish and readable.
require 'json'

puts '----- build_binary_tree([1, 2, 3, 4, 5, 6, 7]) -----'
puts JSON.pretty_generate(build_binary_tree([1, 2, 3, 4, 5, 6, 7]))
puts '----- build_binary_tree([1, nil, 3, 4, 5, 6, 7]) -----'
puts JSON.pretty_generate(build_binary_tree([1, nil, 3, 4, 5, 6, 7]))
puts '----- iterative_binary_tree([1, 2, 3, 4, 5, 6, 7]) -----'
puts JSON.pretty_generate(iterative_binary_tree([1, 2, 3, 4, 5, 6, 7]))
puts '----- iterative_binary_tree([1, nil, 3, 4, 5, 6, 7]) -----'
puts JSON.pretty_generate(iterative_binary_tree([1, nil, 3, 4, 5, 6, 7]))
