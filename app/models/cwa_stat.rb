class CwaStat < ActiveRecord::Base
  attr_accessible :cputime, :date, :job_count, :user_id, :wallclock
end
