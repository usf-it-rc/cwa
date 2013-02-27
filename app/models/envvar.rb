class Envvar < ActiveRecord::Base
  belongs_to :cwa_application
  attr_accessible :name, :value
end
