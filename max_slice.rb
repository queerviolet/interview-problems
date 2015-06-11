<<-DOC

Given an array of numbers, return the slice with the largest sum.

Q: What's a slice?
A: It's a contiguous piece of the array (no holes)

This array: [1, 2, 3, 4]
  Has these slices:
    []
    [1] [2] [3] [4]
    [1, 2] [2, 3] [3, 4]
    [1, 2, 3] [2, 3, 4]
    [1, 2, 3, 4]
  But not these:
    [1, 2, 4]
    [1, 3]
    [1, 3, 4]
    (because they have holes)

Function signature:

    max_slice([Number]) -> [Number]

Examples:

    max_slice([]) -> []

    max_slice([-1, -2, -3]) -> [-1]

    max_slice([1, 2, 3, 4]) -> [1, 2, 3, 4]

    max_slice([-10000, 2, 3, 4]) -> [2, 3, 4]

    # [10, 20, -5, 2, 3] may also be valid:
    max_slice([10, 20, -5, 2, 3]) -> [10, 20]

    max_slice([10, 20, -5, 2, 3, 1, -10]) -> [10, 20, -5, 2, 3, 1]

DOC

require 'minitest/autorun'

describe :max_slice do
  it 'returns an empty slice if given an empty array' do
    max_slice([]).must_equal []
  end

  it 'returns an slice of one if given an entirely negative array' do
    max_slice([-1, -2, -3]).must_equal [-1]
  end

  it 'returns the entire array if that is the largest slice' do
    max_slice([1, 2, 3, 4]).must_equal [1, 2, 3, 4]
  end

  it 'will slice off the first or last element appropriately' do
    max_slice([-10000, 2, 3, 4]).must_equal [2, 3, 4]
    max_slice([2, 3, 4, -1000]).must_equal [2, 3, 4]
  end

  it 'will return the shortest slice it can' do
    max_slice([10, 20, -5, 2, 3]).must_equal [10, 20]
  end

  it 'will not succumb to local minima' do
    max_slice([10, 20, -5, 2, 3, 1, -10]).must_equal [10, 20, -5, 2, 3, 1]
  end
end

# -- Big-O primer --
#
# O(1) — constant time
#   takes the same amount of time no matter how large the input set.
#   no loops, just math & memory operations
#   looking up in an array by index is O(1): load(start_of_array + index)
#   hash insertion is O(1): store(value, start_of_array + hash(key)), where
#     hash(key) is some O(1) function (handwave collisions).
# O(n) — linear time
#   do an O(1) thing to each thing: each, map, reduce, min, max on
#   an unstructured array
# O(log_2 n) — logarithmic time
#   when you see log_2, you're working on a problem where you can eliminate
#   half your dataset with each step. Often seen with binary tree operations.
#   lookup / insertion into a binary tree, binary search, binary heap insertion
# O(n^2) — polynomial time
#   compare each to each (find all pairs in an unstructured array)
#   for a in ary:
#     for b in ary:
#       do some O(1) thing
# O(n^k) — still polynomial time, but worse as k grows
#   More nested loops.
# O(n * log_2 n)
#   sorting. Note that heap insertion is O(log_2 n), and so putting everything
#   into a heap and taking it all out again is O(n * log_2 n), and indeed,
#   that algorithm is called heap sort.
# O(2^n)
#   all subsets of n things
# O(n!)
#   exhaustive searches over all permutations.
#   There are 9! tic tac toe games; that's 362,880, making it one of the
#   few common games for which you can exhaustively search all possible
#   moves and their consequences.

# max_slice_exhaustive(ary: []Number) -> []Number
#
# Return the slice of ary with the largest sum by exhaustively
# searching all valid slices. This one is O(n^3).
def max_slice_exhaustive(ary)
  best_slice = nil
  best_sum = -Float::INFINITY
  ary.length.times do |start_index| # O(n)
    (start_index..ary.length - 1).each do |end_index| # * O(n)
      slice = ary[start_index..end_index]
      sum = slice.inject(:+) # * O(n)
      if sum > best_sum
        best_slice = slice
        best_sum = sum
      end
    end
  end
  best_slice
end

# max_slice(ary: []Number) -> []Number
#
# Return the slice of ary with the largest sum. Considers only
# n slices, but it turns out that's enough.
#
# We walk the array exactly once, keeping track of a cumulative
# sum from an arbitrary start index (initially zero). Keep track
# of the best slice (highest cumulative sum) ever seen, and
# reset the current start index and zero the current sum any time
# the latter dips below zero.
#
# This makes one pass over the array—it's O(n).
def max_slice(ary)
  best_start = 0
  best_end = -1
  best_sum = -Float::INFINITY
  current_sum = 0
  current_start = 0
  ary.each.with_index do |x, i|
    if current_sum < 0
      current_start = i
      current_sum = 0
    end
    current_sum += x
    if current_sum > best_sum
      best_sum = current_sum
      best_start = current_start
      best_end = i
    end
  end
  ary[best_start..best_end]
end