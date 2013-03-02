class CwaDefaultController < ApplicationController
  unloadable

  def not_activated
    @project = Project.find(Redmine::Cwa.project_id)

    respond_to do |format|
      format.html
    end
  end
end
