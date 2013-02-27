require 'rsgejobs.rb'

class CwaJobmanagerController < ApplicationController
  unloadable

  def index
    @project = Project.find(Redmine::Cwa.project_id)
    @jobs = RsgeJobs.new User.current.login
    respond_to do |format|
      format.html
    end
  end

  def delete
    jobs = RsgeJobs.new User.current.login
    job = jobs.where_id_is params[:jobid]

    if job.delete
      flash[:notice] = "Job #{params[:jobid]} deleted!"
    else
      flash[:error] = "Problem deleting job #{params[:jobid]}!"
    end
    redirect_to :action => 'index'
  end

  def submit
  
  end

end
