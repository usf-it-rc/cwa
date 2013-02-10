class CwaGroupmanagerController < ApplicationController
  unloadable

  def index
   @project = Project.find(Redmine::Cwa.project_id)
   @groups = CwaGroups.new
   respond_to do |format|
      format.html
    end
  end

end
