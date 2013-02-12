class CwaGroupRequests < ActiveRecord::Base
  unloadable
  attr_accessible :group_id, :user_id
  validates_numericality_of :group_id
  validates_numericality_of :user_id
end
