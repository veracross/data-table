# Custom Enumerable methods
module Enumerable
  # Use a set of provided groupings to transform a flat array of
  # hashes into a nested hash.
  # groupings should be passed as an array of hashes.
  # e.g. groupings = [{level: 0}, {level: 1}, {level: 2}]
  def group_by_recursive(groupings)
    groupings.sort_by! { |l| l["value"] }
    groups = group_by { |row| row[groupings.first.keys[0]] }
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
        v.each_pair_recursive { |k, v| yield k, v }
      else
        yield(k, v)
      end
    end
  end
end
