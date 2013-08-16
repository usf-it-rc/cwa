class FixColumnNameCwaAllocations < ActiveRecord::Migration
  change_table :cwa_allocations do |t|
    t.rename :type, :allocation_type
  end
end
