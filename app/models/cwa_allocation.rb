class CwaAllocation < ActiveRecord::Base
  unloadable
  attr_accessible :user_id, :approved, :proposal, :time_in_hours, :time_submitted, :time_approved,
                  :used_hours, :summary

  validates_presence_of :proposal, :presence => true
  validates_presence_of :time_in_hours, :presence => true
  validates_presence_of :user_id, :presence => true
  validates_presence_of :summary, :presence => true
  validates_presence_of :time_submitted, :presence => true
  validates_numericality_of :user_id
  validates_numericality_of :time_in_hours

end
