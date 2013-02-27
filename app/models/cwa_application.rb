class CwaApplication < ActiveRecord::Base
  unloadable
  attr_accessible :name, :version, :exec, :haml_form
  has_many :envvars
  has_one :name
  accepts_nested_attributes_for :envvars, :allow_destroy => true
end
