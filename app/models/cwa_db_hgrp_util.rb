class CwaDbHgrpUtil < ActiveRecord::Base
  attr_accessible :free_mem, :free_swap, :hgrp_id, :last_update, :nice_cpu_util, :sys_cpu_util, :user_cpu_util
end
