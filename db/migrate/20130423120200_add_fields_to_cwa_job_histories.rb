class AddFieldsToCwaJobHistories < ActiveRecord::Migration
  change_table :cwa_job_histories do |t|
    t.text :submit_parameters
    t.integer :app_id
  end
end
