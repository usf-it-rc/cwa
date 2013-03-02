class CwaApplication < ActiveRecord::Base
  unloadable
  attr_accessible :name, :version, :exec, :haml_form
end
