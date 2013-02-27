class CwaApplicationsController < ApplicationController
  unloadable

  def newapp
    @project = Project.find(Redmine::Cwa.project_id)
    @app = CwaApplication.new
    respond_to do |format|
      format.html
    end
  end

  def create
    Rails.logger.debug params.to_s
    if CwaApplication.create params
      flash[:notice] = "Application #{params[:name]} successfully defined!"
    else
      flash[:error] = "Problem adding #{params[:name]}!"
    end
    redirect_to :action => 'apps'
  end

  def index
    @project = Project.find(Redmine::Cwa.project_id)
    @apps = CwaApplication.all
    respond_to do |format|
      format.html
    end
  end

end
