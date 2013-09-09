class ThreadTracker < Thread

  attr_accessor :tid, :opid, :thread, :pool, :user, :timeout, :expired
  @@object_pool = []
  
  def initialize(&block)

    self.user = User.current.login
    self.opid = Digest::SHA512.hexdigest("ThreadTrackerSalt" + 
      (Time.now.to_i+Time.now.tv_usec+Time.now.tv_nsec).to_s + block.to_s)

    # add this to op thread cache
    thread_list = Rails.cache.read("#{self.user}_thread_list")
    if thread_list.nil?
      Rails.cache.write("#{self.user}_thread_list", { self.opid => nil})
    else
      thread_list.merge!({self.opid => nil})
      Rails.cache.write("#{self.user}_thread_list", thread_list)
    end

    self.status = { :status => "Starting" }

    # add cache entry item
    Rails.cache.write(self.opid, self.status)

    Rails.logger.debug "#{user} kicking off thread #{tid} #{opid}"

    # kick off actual background task
    self.thread = super do
      Thread.current.thread_variable_set(:opid, self.opid)
      Rails.logger.debug "#{user}:#{opid}:#{block.to_s}"
      begin
        yield block
      ensure
        Rails.logger.flush
      end
      Thread.current.exit
    end

    # Still need this for find_thread_by_opid to work
    @@object_pool << self
    self
  end  

  def expire
    return if self.expired?
    Rails.cache.write(self.opid, Rails.cache.read(self.opid), :expires_in => 60.seconds)
    t_list = Rails.cache.read("#{User.current.login}_thread_list")
    t_list[self.opid] = Time.now + 30.seconds
    Rails.cache.write("#{User.current.login}_thread_list", t_list)
    Rails.logger.debug "ThreadTracker.expire() #{t_list.to_s}"
    Rails.logger.debug "Removing thread #{self.opid}"
    self.expired = true
    self.kill
  end

  def expired?
    self.expired
  end

  def status=(stat)
    cur_stat = Rails.cache.read(self.opid)
    if cur_stat.nil?
      Rails.cache.write(self.opid, stat)
    else
      Rails.cache.write(self.opid, cur_stat.merge(stat))
    end
  end

  def status
    Rails.cache.read(self.opid)
  end

  # Here's our class methods
  class << self
    # clean up old threads
    def gc
      Rails.logger.debug "ThreadTracker Garbage Collector"
      @@object_pool.each do |t| 
        t.expire if !t.alive?
      end
      
      # delete any old opids from the opid list
      t_list = Rails.cache.read("#{User.current.login}_thread_list")
      if !t_list.nil?
        t_list.keys.each do |o|
          t_list.delete(o) if !t_list[o].nil? and t_list[o] <= Time.now 
        end
        Rails.cache.write("#{User.current.login}_thread_list", t_list)
      end
        
    end

    def my_ops
      t_list = Rails.cache.read("#{User.current.login}_thread_list")
      return nil if t_list.nil?
      t_list.keys
    end 

    def current
      opid = Thread.current.thread_variable_get(:opid)
      if opid.nil?
        Rails.logger.debug "We're not in a thread!"
        return nil
      else
        t = find_thread_by_opid opid
        Rails.logger.debug "ThreadTracker.current returning #{t.to_s}"
        return t
      end
    end

    def cache_status(opid)
      resp = { opid => Rails.cache.read(opid) }
      Rails.logger.debug "ThreadTracker.cache_status() => #{resp.to_s}"
      resp
    end

    def find_thread_by_opid(opid)
      Rails.logger.debug "find_thread(#{opid})"
      @@object_pool.each do |t| 
        Rails.logger.debug "find_thread(#{t.to_s})"
        return t if t.opid == opid
      end

    end
  end

end
