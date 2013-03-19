class CreateCwaDbGrpUtils < ActiveRecord::Migration
  def change
    create_table :cwa_db_grp_utils do |t|
      t.integer :grp_id
      t.integer :grp_own_id
      t.integer :grp_hd_util

      t.timestamps
    end
  end
end
