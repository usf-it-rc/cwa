class CreateCwaDashboards < ActiveRecord::Migration
  def change
    create_table :cwa_dashboards do |t|
      t.integer :user_id
      t.integer :hd_usage
    end
  end
end
