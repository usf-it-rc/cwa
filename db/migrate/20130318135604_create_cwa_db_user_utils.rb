class CreateCwaDbUserUtils < ActiveRecord::Migration
  def change
    create_table :cwa_db_user_utils do |t|
      t.integer :user_id
      t.integer :cpu_hrs
      t.integer :ave_mem_job
      t.integer :curr_hd_util
      t.date :last_update

      t.timestamps
    end
  end
end
