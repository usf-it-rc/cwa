class CwaApplication < ActiveRecord::Base
  unloadable
  attr_accessible :name, :version, :exec, :haml_form, :project_id
  validates_presence_of :name
  validates_presence_of :version
  validates_presence_of :exec
  validates_presence_of :haml_form
  validates_numericality_of :project_id
end
