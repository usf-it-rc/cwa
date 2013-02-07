class CwaAllocation < ActiveRecord::Base
  unloadable
  attr_accessible :user_id, :approved, :proposal, :time_in_hours, :time_submitted, :time_approved,
                  :used_hours, :summary

  validates :proposal, :presence => true
  validates :time_in_hours, :presence => true
  validates :user_id, :presence => true
  validates :summary, :presence => true
  validates :time_submitted, :presence => true

  after_validation :log_errors, :if => Proc.new {|m| m.errors}

  def log_errors
    Rails.logger.debug self.errors.full_messages.join("\n")
  end
end
