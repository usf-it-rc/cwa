class CreateCwaAllocations < ActiveRecord::Migration
  def change
    create_table :cwa_allocations do |t|
      t.integer :time_in_hours
      t.text :proposal
      t.text :summary
      t.boolean :approved
      t.timestamp :time_submitted
      t.timestamp :time_approved
      t.integer :used_hours 
      t.integer :user_id
    end
  end
end
