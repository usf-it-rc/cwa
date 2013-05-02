class AddFieldsToCwaApplications < ActiveRecord::Migration
  change_table :cwa_applications do |t|
    t.integer :project_id
  end
end
