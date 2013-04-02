class CreateCwaUserMetrics < ActiveRecord::Migration
  def change
    create_table :cwa_user_metrics do |t|
      t.integer :user_id
      t.integer :cpu_time
      t.float :cpu_time_job, :length => 22, :precision => 16
      t.integer :job_time
      t.float :disk_usage_home, :length => 22, :precision => 16
      t.float :disk_usage_work, :length => 22, :precision => 16
      t.integer :tot_jobs
    end
  end
end
