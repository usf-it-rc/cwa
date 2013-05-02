class CwaDefaultController < ApplicationController
  unloadable

  def not_activated
    @project = Project.find(params[:project_id])

    respond_to do |format|
      format.html
    end
  end
  def unavailable
    @project = Project.find(params[:project_id])

    respond_to do |format|
      format.html
    end
  end
  def authorization
    @project = Project.find(params[:project_id])

    respond_to do |format|
      format.html
    end
  end
end
