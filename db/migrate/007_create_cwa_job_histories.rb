class CreateCwaJobHistories < ActiveRecord::Migration
  def change
    create_table :cwa_job_histories do |t|
      t.string :owner
      t.string :jobid
      t.string :workdir
      t.string :job_name
    end
  end
end
