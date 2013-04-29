class CwaApplication < ActiveRecord::Base
  unloadable
  attr_accessible :name, :version, :exec, :haml_form
  validates_presence_of :name
  validates_presence_of :version
  validates_presence_of :exec
  validates_presence_of :haml_form
end
