class CwaBrowser
  attr_accessor :current_dir, :current_share, :current_path, :user
  def initialize(share, dir)
    @user = CwaIpaUser.new

    if share =~ /^(\/[^\0]+\/)+/
      (share,dir) = self.resolve_path_from_string(share)
    end

    if dir != nil
      case share
      when "home"
        path = user.homedirectory + "/" + dir.to_s
      when "shares"
        path = "/shares/" + dir
      when "work"
        path = user.workdirectory + "/" + dir.to_s
      else
        raise ArgumentError, "You cannot browse directories outside of your home, work, or group share paths."
      end
    else
      case share
      when "home"
        path = user.homedirectory
      when nil
        share = "home"
        path = user.homedirectory
      when "shares"
        raise ArgumentError, "Not a valid share path!"
      when "work"
        path = user.workdirectory
      else
        raise ArgumentError, "You cannot browse directories outside of your home, work, or group share paths."
      end
    end

    if Redmine::CwaBrowserHelper.type(path) !~ /application\/x\-directory/
      raise ArgumentError, "No such directory!"
    end

    self.current_dir = dir.to_s.chomp.to_s
    self.current_share = share.chomp
    self.current_path = path

  end

  # Return string of one directory up
  def up_dir
    if self.current_dir !~ /[\/]+.*/
      return ""
    else
      self.current_dir.gsub(/(.*)\/.*$/, '\1')
    end
  end

  # return list of directories in the current path
  def directories
    dirs = Array.new
    lines = Redmine::CwaBrowserHelper.userexec("list #{self.current_path} -- d")[0]

    lines.each_line do |line| 
      entry = line.chomp.gsub("\"","")
      dirs.push entry if entry != ""
    end

    return dirs
  end

  # return list of files in the current path
  def files
    fs = Array.new
    lines = Redmine::CwaBrowserHelper.userexec("list #{self.current_path} -- f")[0]

    lines.each_line do |line| 
      entry = line.chomp.gsub("\"","")
      fs.push entry if entry != ""
    end

    return fs
  end

  def resolve_path
    if self.current_dir != nil
      case self.current_share
      when "home"
        file = user.homedirectory + "/" + self.current_dir
      when "work"
        file = user.workdirectory + "/" + self.current_dir
      when "shares"
        file = "/shares/" + self.current_dir
      end
    else
      case self.current_share
      when "home"
        file = user.homedirectory
      when "work"
        file = user.workdirectory
      when "shares"
        file = nil
      end
    end
    file
  end

  def resolve_path_from_string(str)
    share_paths = { home: user.homedirectory, work: user.workdirectory, shares: "/shares/" }
    share = ""
    
    share_paths.keys.each do |path|
      Rails.logger.debug "resolve_path_from_string => #{str} #{share_paths[path]}"
      share = path if str.match(share_paths[path])
    end
 
    dir = str.gsub(share_paths[share], "")
    dir.gsub!(/^\//,'')

    Rails.logger.debug "resolve_path_from_string => #{str} => #{share.to_s} #{dir}"
    return [ share.to_s, dir ]
  end
end
