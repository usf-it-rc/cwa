class AddFieldsToCwaAllocations < ActiveRecord::Migration
  change_table :cwa_allocations do |t|
    t.integer :type
  end
end
