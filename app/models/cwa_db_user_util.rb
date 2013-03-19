class CwaDbUserUtil < ActiveRecord::Base
  attr_accessible :ave_mem_job, :cpu_hrs, :curr_hd_util, :last_update, :user_id
end
