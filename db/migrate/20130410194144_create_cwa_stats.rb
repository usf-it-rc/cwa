class CreateCwaStats < ActiveRecord::Migration
  def change
    create_table :cwa_stats do |t|
      t.integer :user_id
      t.integer :job_count
      t.integer :wallclock
      t.integer :cputime
      t.date :date

      t.timestamps
    end
    add_index :cwa_stats, :user_id
  end
end
