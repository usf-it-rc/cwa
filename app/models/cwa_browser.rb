class CwaBrowser
  attr_accessor :current_dir, :current_share, :current_path, :user, :home, :work
  def initialize(share, dir)
    @user = CwaIpaUser.new

    @home = user.homedirectory
    @work = user.workdirectory

    if share =~ /^(\/[^\0]+\/)+/
      (share,dir) = self.resolve_path_from_string(share)
    end

    if dir != nil
      case share
      when "home"
        path = home + "/" + dir.to_s
      when "shares"
        path = "/shares/" + dir
      when "work"
        path = work + "/" + dir.to_s
      else
        raise ArgumentError, "You cannot browse directories outside of your home, work, or group share paths."
      end
    else
      case share
      when "home"
        path = home
      when nil
        share = "home"
        path = home
      when "shares"
        raise ArgumentError, "Not a valid share path!"
      when "work"
        path = work
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
        file = home + "/" + self.current_dir
      when "work"
        file = work + "/" + self.current_dir
      when "shares"
        file = "/shares/" + self.current_dir
      end
    else
      case self.current_share
      when "home"
        file = home
      when "work"
        file = work
      when "shares"
        file = nil
      end
    end
    file
  end

  def resolve_path_from_string(str)
    share_paths = { home: home, work: work, shares: "/shares/" }
    share = ""
    
    share_paths.keys.each do |path|
      share = path if str.match(share_paths[path])
    end
 
    dir = str.gsub(share_paths[share], "")
    dir.gsub!(/^\//,'')

    return [ share.to_s, dir ]
  end
end
