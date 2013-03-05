require 'cwa_rest'
include ::CwaRest

class CwaGroups
  @@groups = nil
  @@allGroups = nil

  def initialize(&block)
    yield self if block !=nil
  end

  # Get list of groups I manage from JSON-RPC
  def that_i_manage
    group_list = Array.new
    get_groups.each do |g|
      group_list << g if g[:owner] == User.current.login
    end
    group_list
  end 

  # Get list of groups I belong to from JSON-RPC, not groups I manage
  def member_of
    group_list = Array.new
    get_groups.each do |g|
      group_list << g if g[:owner] != User.current.login
    end
    group_list
  end

  def by_name(name)
    get_all_groups.each do |g| 
      return g if g[:cn].first.to_i == name
    end
  end

  def by_id(id)
    get_all_groups.each do |g| 
      return g if g[:gidnumber].first.to_i == id.to_i
    end
  end

  def from_all_by_id(id)
    get_all_groups.each { |g| g if g[:gidnumber] == id }
  end

  def from_all_by_name(name)
    get_all_groups.each do |g| 
      return g if g[:cn] == name
    end
  end

  def delete_me_from_group(group)
    res = Redmine::IPAGroup.remove_user User.current.login, group
    refresh_groups
    res
  end

  def add_to_my_group(user, group)
    res = Redmine::IPAGroup.add_user user, group
    refresh_groups
    res
  end
 
  def create(group_info)
    res = Redmine::IPAGroup.create_new_group(group_info)
    refresh_groups
    res
  end

  def delete(name)
    res = Redmine::IPAGroup.delete_group(name)
    refresh_groups
    res
  end

  def delete_from_my_group(user, group)
    res = Redmine::IPAGroup.remove_user user, group
    refresh_groups
    res
  end

  def all_groups
    get_all_groups
  end

  private
  def refresh_groups
    if @@allGroups != nil
      @@allGroups[:timestamp] -= 60.seconds
    end

    if @@groups != nil && @@groups[User.current.login] != nil
      @@groups[User.current.login][:timestamp] -= 60.seconds
    end
    get_groups
    get_all_groups
  end

  def get_all_groups
    # Caching, baby
    @@allGroups = { :timestamp => Time.now, :groups => Array.new } if @@allGroups == nil

    if (Time.now - @@allGroups[:timestamp]) <= 30.seconds && @@allGroups[:groups] != []
      return @@allGroups[:groups] 
    else
      @@allGroups = { :timestamp => Time.now, :groups => Array.new }
    end

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
      @@allGroups[:groups] << g
    end
    @@allGroups[:groups]
  end

  def get_groups
    # Caching, baby
    @@groups = { User.current.login => { :timestamp => Time.now, :groups => Array.new }} if @@groups == nil
    @@groups = { User.current.login => { :timestamp => Time.now, :groups => Array.new }} if !@@groups.has_key?(User.current.login)

    if ((Time.now - @@groups[User.current.login][:timestamp]) <= 30.seconds) && (@@groups[User.current.login][:groups] != [])
      return @@groups[User.current.login][:groups] 
    else
      @@groups = { User.current.login => {:timestamp => Time.now, :groups => Array.new }}
    end

    response = Redmine::IPAGroup.find_by_user(User.current.login)['result']['result']

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
      @@groups[User.current.login][:groups] << g
    end
    @@groups[User.current.login][:groups]
  end
end
