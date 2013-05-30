require 'cwa_rest'
include ::CwaRest

class CwaGroups
  attr_accessor :user

  def initialize(&block)
    self.user = User.current

    # initialize the cache
    all_groups
    user_groups
    yield self if block !=nil
  end

  #
  # QUERY-ONLY METHODS
  # 

  # Get list of groups I manage from JSON-RPC
  def that_i_manage
    group_list = Array.new
    user_groups.each do |g|
      group_list << g if g[:owner] == self.user.login.downcase
    end
    group_list
  end 

  # Get list of groups I belong to from JSON-RPC, not groups I manage
  def member_of
    group_list = Array.new
    user_groups.each do |g|
      group_list << g if g[:owner] != self.user.login.downcase
    end
    group_list
  end

  # Get group by name
  def by_name(name)
    all_groups.each do |g| 
      Rails.logger.debug "by_name() => #{g.to_s}"
      return g if g[:cn].to_s == name
    end
  end

  # get group by gidnumber
  def by_id(id)
    group = {}
    all_groups.each do |g| 
      next if g[:gidnumber] == nil
      return g if g[:gidnumber].first.to_i == id.to_i
    end
  end

  #
  # VOLATILE METHODS
  #

  # Remove self.user from group membership of specified group
  def delete_me_from_group(group)
    res = Redmine::IPAGroup.remove_user self.user.login, group
    refresh
    res
  end

  # Add a user to self.user's group
  # TODO: Validate that self.user is owner of group
  def add_to_my_group(user, group)
    res = Redmine::IPAGroup.add_user user, group
    refresh
    res
  end
 
  # Create a new group
  def create(group_info)
    res = Redmine::IPAGroup.create_new_group(group_info)
    refresh
    res
  end

  # Delete a group
  def delete(name)
    res = Redmine::IPAGroup.delete_group(name)
    refresh
    res
  end

  # Delete a user from self.user's group
  # TODO: Validate that self.user is owner of group
  def delete_from_my_group(user, group)
    res = Redmine::IPAGroup.remove_user user, group
    refresh
    res
  end

  # Retrieve array of all groups w/ caching
  def all_groups
    groups = Rails.cache.fetch("all_groups", :expires_in => 60.seconds) do
      get_all_groups
    end
    return groups
  end

  # TODO: refactor method to use map() to filter out non-member groups from "all_groups" cache
  #       eliminating  extra IPA query
  #
  # Retrieve array of groups to which self.user belongs w/ caching
  def user_groups
    groups = Rails.cache.fetch("user_groups_#{self.user.login.downcase}", :expires_in => 60.seconds) do
      get_user_groups
    end
    return groups
  end

  private
  # clear our caches (usually called after volatile methods)
  def refresh
    Rails.cache.clear("all_groups")
    Rails.cache.clear("user_groups_#{self.user.login.downcase}")
  end

  def get_all_groups
    allgroups = Array.new
    response = Redmine::IPAGroup.find_all['result']['result']
    response.each do |r|
      next if r['cn'].first == "ipausers"

      g = { 
        :cn => r['cn'].first, 
        :members => r['member_user'],
        :gidnumber => r['gidnumber']
      }

      # Ugh... we'll have to eval this into a hash
      case r['description'].first
      when /^{.*}$/
        h = eval r['description'].first
        g[:desc] = h[:desc]
        g[:owner] = h[:owner] 
      when "null"
        g[:desc] = "No description"
        g[:owner] = "admins"
      else
        g[:desc] = r['description'].first
        g[:owner] = "admins"
      end

      allgroups << g
    end
   return allgroups
  end

  # TODO: This method should be deprecated soon
  def get_user_groups
    groups = Array.new
    response = Redmine::IPAGroup.find_by_user(self.user.login.downcase)['result']['result']
    response.each do |r|
      next if r['cn'].first == "ipausers"

      g = { 
        :cn => r['cn'].first, 
        :members => r['member_user'],
        :gidnumber => r['gidnumber']
      }

      # Ugh... we'll have to eval this into a hash
      case r['description'].first
      when /^{.*}$/
        h = eval r['description'].first
        g[:desc] = h[:desc]
        g[:owner] = h[:owner] 
      when "null"
        g[:desc] = "No description"
        g[:owner] = "admins"
      else
        g[:desc] = r['description'].first
        g[:owner] = "admins"
      end
      groups << g
    end
    return groups
  end
end
