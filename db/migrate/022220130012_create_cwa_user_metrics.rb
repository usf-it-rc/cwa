class CreateCwaUserMetrics < ActiveRecord::Migration
  def change
    create_table :cwa_user_metrics do |t|
      t.integer :user_id
      t.integer :total_cputime
      t.float :average_cputime, :length => 22, :precision => 16
      t.integer :total_walltime
      t.float :average_walltime, :length => 22, :precision => 16
      t.float :disk_usage_home, :length => 22, :precision => 16
      t.float :disk_usage_work, :length => 22, :precision => 16
      t.integer :total_jobs
    end
  end
end
