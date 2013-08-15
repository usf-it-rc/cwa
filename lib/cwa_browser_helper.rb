require "open3"
require "base64"

module Redmine::CwaBrowserHelper
  class << self
    #def chmod(file, mode)
    #  userexec("chmod #{mode} #{file}")[2] == 0 ? true : false
    #end
     
    def cwa_browser_tab
      tabs = [{:name => 'home', :controller => 'cwa_browser', :action => 'index', :share => 'home' },
              {:name => 'work', :controller => 'cwa_browser', :action => 'index', :share => 'work' }]
    end

    def type(file)
      return userexec("type #{file}")[0].chomp
    end

    def rename(file, new_name)

      id = Digest::SHA512.hexdigest("MySaltySurprise" + 
        (Time.now.to_i+Time.now.tv_usec+Time.now.tv_nsec).to_s +
        file + new_name)

      op_name = "fileop_rename_#{User.current.login}_#{id}"

      myops = Rails.cache.read("file_operations_#{User.current.login}")

      if myops.nil?
        myops = [op_name]
      else
        myops << op_name
      end

      Rails.cache.write("file_operations_#{User.current.login}", myops)

      result = userexec "rename #{file} -- #{new_name}"

      status = Rails.cache.write(op_name, {
          :file_name => file,
          :id => id,
          :progress => 100,
          :status => result[2] == 0 ? 'complete' : 'failed',
          :operation => 'move' 
        }, expires_in: 30.seconds)
      return result[2] == 0 ? true : false
    end

    def remoteMove(source, target, move_id, user)
      op_name = "fileop_move_#{user}_#{move_id}"
      Rails.logger.debug "#{user} => mv #{source} -- #{target}"
      stdin, stdout, stderr, wait_thr = Open3.popen3(
        "sudo -u #{user} /usr/bin/cwabrowserhelper.sh mv #{source} -- #{target}"
        )

      myops = Rails.cache.read("file_operations_#{user}")

      if myops.nil?
        myops = [op_name]
      else
        myops << op_name
      end

      Rails.cache.write("file_operations_#{user}", myops)
      Rails.cache.write(op_name, { 
        :file_name => source,
        :id => move_id,
        :progress => 0,
        :status => 'Starting',
        :operation => 'Move' 
      })

      while !stderr.eof?
        progress = stderr.readline
        Rails.logger.debug "remoteMove: #{progress}"
        Rails.cache.write(op_name, { 
            :file_name => source,
            :id => move_id,
            :progress => progress.to_i.nil? ? 0 : progress.to_i,
            :status => 'In Progress',
            :operation => 'Move' 
          })
      end

      status = Rails.cache.write(op_name, {
          :file_name => source,
          :id => move_id,
          :progress => 100,
          :status => 'Complete',
          :operation => 'Move' 
        }, expires_in: 30.seconds)

      stdout.close
      stdin.close
      stderr.close
      exit_status = wait_thr.value
      return exit_status
    end
      
    def copy(source, target, copy_id, user)
      op_name = "fileop_copy_#{user}_#{copy_id}"
      Rails.logger.debug "#{user} => cp #{source} -- #{target}"
      stdin, stdout, stderr, wait_thr = Open3.popen3(
        "sudo -u #{user} /usr/bin/cwabrowserhelper.sh cp #{source} -- #{target}"
        )

      myops = Rails.cache.read("file_operations_#{user}")

      if myops.nil?
        myops = [op_name]
      else
        myops << op_name
      end

      # Get our first op data into the cache
      Rails.cache.write("file_operations_#{user}", myops)
      Rails.cache.write(op_name, { 
        :file_name => source,
        :id => copy_id,
        :progress => 0,
        :status => 'starting',
        :operation => 'Copy' 
      })

      while !stderr.eof?
        progress = stderr.readline
        Rails.logger.debug "COPY: #{progress}"
        Rails.cache.write(op_name, { 
          :file_name => source,
          :id => copy_id,
          :progress => progress.to_i.nil? ? 0 : progress.to_i,
          :status => 'in_progress',
          :operation => 'Copy' 
        })
      end

      status = Rails.cache.write(op_name, {
        :file_name => source,
        :id => copy_id,
        :progress => 100,
        :status => 'complete',
        :operation => 'Copy' 
      }, expires_in: 30.seconds)

      stdout.close
      stdin.close
      stderr.close
      exit_status = wait_thr.value
      return exit_status
    end

    def delete(file)
      Rails.logger.debug "userexec rm #{file}"
      # TODO: Make this safer!
      result = userexec "rm #{file}"
      Rails.logger.debug "Redmine::CwaBrowserHelper.delete() #{result.to_s}"
      return result[2] == 0 ? true : false
    end

    def mkdir(file)
      Rails.logger.debug "userexec mkdir #{file}"
      result = userexec "mkdir #{file}"
      Rails.logger.debug "Redmine::CwaBrowserHelper.mkdir() #{result.to_s}"
      return result[2] == 0 ? true : false
    end

    def file_size(file)
      (size,err,code) = userexec "stat #{file}"
      size = size.chomp.to_i
      size
    end

    def file_lines(file)
      (size,err,code) = userexec "lines #{file}"
      size = size.chomp.to_i
      size
    end
    
    # Wicked cool privileged file writer 
    class Redmine::CwaBrowserHelper::Put
      @desc = nil
      @remote_file = nil
      
      def initialize(file)
        @remote_file = file
        Rails.logger.debug "Redmine::CwaBrowserHelper::Put => sudo -u #{User.current.login} /usr/bin/cwabrowserhelper.sh write #{file}"
        @desc = IO.popen("sudo -u #{User.current.login} /usr/bin/cwabrowserhelper.sh write #{file}", "wb")
      end

      def write(data)
        @desc.write(data)
      end

      def done
        @desc.close
      end
    end


    # Wicked cool privileged file reader implementation
    class Redmine::CwaBrowserHelper::Retrieve
      @stdout = nil
      @stdin = nil
      @stderr = nil
      @wait_thr = nil
      @file = nil
      
      def initialize(file)
        @file = file
        @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(
          "sudo -u #{User.current.login} /usr/bin/cwabrowserhelper.sh read #{file}"
          )
        pid = @wait_thr[:pid]
      end

      def each
        while !@stdout.eof? 
          data = @stdout.read(1024*128)
          yield data
        end
        self.done
      end

      def each_tail
        lines_read = 0
        lines = Redmine::CwaBrowserHelper.file_lines(@file)
        lines_max = 20
        while !@stdout.eof?
          line = @stdout.readline
          lines_read += 1
          if (lines_read >= lines - lines_max)
            yield line
          end
        end
      end

      def seek(offset)
        @stdout.seek(offset.to_i) if offset.to_i != 0
      end

      def done
        @stdout.close
        @stdin.close
        @stderr.close
        exit_status = @wait_thr.value
        return exit_status
      end
    end

    # Return a directory as a zip file :)
    class Redmine::CwaBrowserHelper::RetrieveZip
      @stdout = nil
      @stdin = nil
      @stderr = nil
      @wait_thr = nil
      @file = nil

      def initialize(file)
        @file = file
        file_name = file.split("/").last
        dir = file.gsub(/\/#{file_name}$/,"") 
        @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(
          "sudo -u #{User.current.login} /usr/bin/cwabrowserhelper.sh zip #{dir} -- #{file_name}"
          )
        pid = @wait_thr[:pid]
      end

      def each
        while !@stdout.eof? 
          data = @stdout.read(1024*128)
          yield data
        end
        self.done
      end

      def done
        @stdout.close
        @stdin.close
        @stderr.close
        exit_status = @wait_thr.value
        return exit_status
      end
    end

    def tail(file_name)
      file = Redmine::CwaBrowserHelper::Retrieve.new(file_name)
      return file
    end

    def userexec(cmd)
      output = ""
      error  = ""

      stdin, stdout, stderr, wait_thr = Open3.popen3("sudo -u #{User.current.login} /usr/bin/cwabrowserhelper.sh " + cmd, :chdir => "/tmp")

      pid = wait_thr[:pid]
      stdin.close
      stdout.each_line { |line| output += line }
      stderr.each_line { |line| error += line }
      stdout.close
      stderr.close
      exit_status = wait_thr.value

      return [output,error,exit_status] 
    end

  end
end
