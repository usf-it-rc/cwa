require 'rsgejob'

class CwaApplicationsController < ApplicationController
  unloadable

  def new
    @app = CwaApplication.new
    @project = Project.find(Redmine::Cwa.project_id)
    render :action => 'show'
  end

  def show
    @user = CwaIpaUser.new
    (redirect_to :controller => 'cwa_default', :action => 'not_activated' and return) if !@user.provisioned?
    @project = Project.find(Redmine::Cwa.project_id)
    @app = CwaApplication.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def update
    if CwaApplication.update(params[:id], params[:cwa_application])
      flash[:notice] = "Application successfully defined!"
    else
      flash[:error] = "Problem adding application!"
    end
    redirect_to :action => 'index'
  end

  def create
    if CwaApplication.create(params[:cwa_application])
      flash[:notice] = "Application successfully defined!"
    else
      flash[:error] = "Problem adding application!"
    end
    redirect_to :action => 'index'
  end

  def delete
    @app = CwaApplication.find(params[:id])
    if @app.destroy
      flash[:notice] = "Successfully deleted application!"
    else 
      flash[:error] = "Problem deleting application!"
    end
    redirect_to :action => 'index'
  end

  def index
    @user = CwaIpaUser.new
    (redirect_to :controller => 'cwa_default', :action => 'not_activated' and return) if !@user.provisioned?
    @project = Project.find(Redmine::Cwa.project_id)
    @apps = CwaApplication.all
    respond_to do |format|
      format.html
    end
  end

  def display
    @user = CwaIpaUser.new
    (redirect_to :controller => 'cwa_default', :action => 'not_activated' and return) if !@user.provisioned?
    @project = Project.find(Redmine::Cwa.project_id)
    @app = CwaApplication.find(params[:id])
    @job = RsgeJob.new
    @times = Array.new

    (1..168).to_a.each { |t| @times << t.to_s + ":00:00" }


    haml =  "%h2 Run #{@app.name} v#{@app.version}\n" + @app.haml_form
    Rails.logger.debug "CwaApplicationController.display() => " + haml
    render :inline => haml, :type => 'haml', :layout => true
  end

end
