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

# O(1) -- looking up in an array by index, hash insertion / deletion
# O(n) -- each, map, reduce

# O(log n) -- lookup / insertion into a binary tree

# O(n^2) -- compare each to each
# O(n log n)
# O(2^n) -- look at every possible subset of a set of things

# This is O(n^3)
def max_slice_expensive(ary)
  best_slice = nil
  best_sum = -Float::INFINITY
  ary.length.times do |start_index| # N
    (start_index..ary.length - 1).each do |end_index| # * N
      slice = ary[start_index..end_index]
      sum = slice.inject(:+) # * N
      if sum > best_sum
        best_slice = slice
        best_sum = sum
      end
    end
  end
  best_slice
end

# Walk the array exactly once, keeping track of a cumulative
# sum from an arbitrary start index (initially zero). Keep track
# of the best slice (highest cumulative sum) ever seen, and
# reset the start index and sum any time it dips below zero.
#
# O(n)
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