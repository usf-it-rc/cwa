class CreateCwaDbHgrpUtils < ActiveRecord::Migration
  def change
    create_table :cwa_db_hgrp_utils do |t|
      t.integer :free_mem
      t.integer :free_swap
      t.integer :user_cpu_util
      t.integer :sys_cpu_util
      t.integer :nice_cpu_util
      t.date :last_update
      t.integer :hgrp_id

      t.timestamps
    end
  end
end
