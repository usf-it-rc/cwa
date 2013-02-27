class CreateCwaApplications < ActiveRecord::Migration
  def change
    create_table :cwa_applications do |t|
      t.string :name
      t.string :version
      t.text :exec
      t.text :environment
      t.text :haml_form
    end
  end
end
