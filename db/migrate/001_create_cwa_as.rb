class CreateCwaAs < ActiveRecord::Migration
  def change
    create_table :cwa_as do |t|
      t.text :tos, :default => "Put your terms of service here"
      t.text :saa, :default => "Put your Service Access Agreement here"
      t.text :delete_saa, :default => "Put your terms of service upon account delete here"
    end
  end
end
