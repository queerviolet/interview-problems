#!/usr/bin/env ruby

# Return all the subsets of a set.

require 'set'

def examples()
  raise 'empty set should -> 1 subset (itself)' unless
    p(subsets(Set[])) == Set[Set[]]

  raise 'set of one should -> 2 subsets' unless
    p(subsets(Set['a'])) == Set[Set[], Set['a']]

  raise 'set of three should -> 8 subsets' unless
    p(subsets(Set['a', 'b', 'c'])) == Set[
      Set[], 
      Set['a'], Set['b'], Set['c'],
      Set['a', 'b'], Set['a', 'c'], Set['b', 'c'],
      Set['a', 'b', 'c']]
end

# -- Notes --
#
# General observation: doing anything with all subsets is at least O(2^n)
#
# Recursive approach:
#   If s is the empty set, return a set of the empty set.
#   Take one item (k) out of the set.
#   Find all subsets of the (remaining) set.
#   Return the set containing the union of all sets from (3) and each set from (3) with k added.
#
# Bitmap approach:
#   Convert set to an array A
#   Let R be the set of results
#   For i = 0 to 2^len(set) - 1
#     Add Set(A[each high bit in i]) to R
#   return R


# subsets(set: Set) -> Set[Set]
#
# Return a set of all subsets of the given set.
def subsets(set)
  return Set[set] if set.empty?
  item = set.first
  set.delete(item)
  subsets = subsets(set)
  return subsets + subsets.map { |s| s + [item] }
end


# subsets(set: Set) -> Set[Set]
#
# Return a set of all subsets of the given set. It does this by counting
# from 0 to 2**n - 1 and treating the counter as a bitmap where each bit
# denotes the inclusion of a particular element of the set under a specific
# ordering.
def subsets_bitwise(set)
  ary = set.to_a
  Set.new (2**ary.length).times.map do |bits|
    Set.new(ary.select.with_index { |x, i| 1 & bits >> i == 1 })
  end
end


# Note that the bitmap approach makes the take a block / return an Enumerator
# straightforward:
def each_subset(set, &blk)
  subsets = Enumerator.new do |enum|
    ary = set.to_a    
    (2**ary.length).times do |bits|
      enum.yield(Set.new(ary.select.with_index { |x, i| 1 & bits >> i == 1 }))
    end
  end
  return subsets.each { |x| blk.yield(x) } if blk
  subsets
end

each_subset(Set[1, 2, 3]) { |x| p x }

examples()