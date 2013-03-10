class CwaBrowser
  attr_accessor :current_dir
  def initialize(dir)
    case dir
    when "HOME"
      self.current_dir = self.home_dir
    when "WORK"
      self.current_dir = self.work_dir
    else
      if dir.chomp.include?(self.home_dir) || dir.chomp.include?(self.work_dir)
        self.current_dir = dir.chomp
      else
        raise ArgumentError, "Don't play games with me.  You cannot browse directories outside of your home or work paths."
      end
    end
  end

  def home_dir
    "/home/#{User.current.login[0,1]}/#{User.current.login}"
  end

  def work_dir
    "/work/#{User.current.login[0,1]}/#{User.current.login}"
  end

  def up_dir
    Rails.logger.debug "up_dir() => " + self.current_dir.gsub(/(.*)\/.*$/, '\1')
    self.current_dir.gsub(/(.*)\/.*$/, '\1')
  end

  def directories
    dirs = Array.new
    pipe = IO.popen("sudo -u #{User.current.login} find #{self.current_dir} ! -path #{self.current_dir} ! -type l ! -iname '.*' -maxdepth 1 -type d -printf \"%f\\n\"")
    pipe.each_line{|line| dirs.push line.chomp }
    pipe.close
    Rails.logger.debug "directories() => " + self.current_dir
    Rails.logger.debug "directories() => " + dirs.to_s
    return dirs.sort
  end
  def files
    fs = Array.new
    pipe = IO.popen("sudo -u #{User.current.login} find #{self.current_dir} ! -path #{self.current_dir} ! -type l ! -iname '.*' -maxdepth 1 -type f -printf \"%f\\n\"")
    pipe.each_line{|line| fs.push line.chomp }
    pipe.close
    Rails.logger.debug "files() => " + self.current_dir
    Rails.logger.debug "files() => " + fs.to_s
    return fs.sort
  end
end
