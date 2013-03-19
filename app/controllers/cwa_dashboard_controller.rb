class CwaDashboardController < ApplicationController
  unloadable

  def index
    
    @project = Project.find(Redmine::Cwa.project_id)

    respond_to do |format|
      format.html
    end
  end
end
