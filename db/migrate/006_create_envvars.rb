class CreateEnvvars < ActiveRecord::Migration
  def change
    create_table :envvars do |t|
      t.string :name
      t.string :value
    end
  end
end
