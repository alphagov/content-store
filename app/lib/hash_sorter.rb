require "deepsort"

class HashSorter
  def self.sort(hash)
    # Deepsort by default will sort keys in an array too -
    # we don't want that, as (for instance) order of links
    # may be important
    hash.deep_sort(array: false)
  end
end
