# frozen_string_literal: true
# Custom Enumerable methods
module Enumerable
  # Use a set of provided groupings to transform a flat array of
  # hashes into a nested hash.
  # groupings should be passed as an array of hashes.
  # e.g. groupings = [{level: 0}, {level: 1}, {level: 2}]
  def group_by_recursive(groupings)
    groups = group_by do |row|
      row[groupings[0]]
    end
    if groupings.count == 1
      groups
    else
      groups.merge(groups) do |_group, elements|
        elements.group_by_recursive(groupings.drop(1))
      end
    end
  end

  # Traverse a given nested hash until we reach values that are
  # not hashes.
  def each_pair_recursive
    each_pair do |k, v|
      if v.is_a?(Hash)
        v.each_pair_recursive { |i, j| yield i, j }
      else
        yield(k, v)
      end
    end
  end

  ##
  # Iterates recusively over a nested collection while keeping track of the
  # ancestor groups.
  #
  # When passing a block with a third variable the parents will be passed to the
  # block as an array. e.g. ['parent1', 'parent2', 'parent3']
  #
  # +limit+ can be passed as an optional integer to limit the depth of recursion.
  #
  # +levels+ is internal use and is used to build the array of ancestors
  #
  def each_pair_with_parents(limit = 0, levels = nil)
    levels ||= []
    each_pair do |k, v|
      levels << k
      if v.is_a? Hash
        v.each_pair_with_parents(limit, levels) { |i, j, next_levels| yield(i, j, next_levels) }
      elsif v.is_a? Array
        levels.pop
        yield(k, v, levels)
      end
    end
    levels.pop
  end
end
