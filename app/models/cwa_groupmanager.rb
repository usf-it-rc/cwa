class CwaGm < ActiveRecord::Base
  has_many :
  
  # Get list of groups I own from JSON-RPC
  def my_groups
    User.current.login

  end 

  # Get list of groups I belong to from JSON-RPC
  def my_memberships

  end

  def add_to_my_group

  end

  def del_from_my_group
 
  end
    
end
