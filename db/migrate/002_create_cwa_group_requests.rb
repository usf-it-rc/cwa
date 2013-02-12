class CreateCwaGroupRequests < ActiveRecord::Migration
  def change
    create_table :cwa_group_requests do |t|
      t.integer :user_id
      t.integer :group_id
    end
  end
end
