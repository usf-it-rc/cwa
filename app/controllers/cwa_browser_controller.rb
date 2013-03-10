class CwaBrowserController < ApplicationController
  unloadable

  def test
    @project = Project.find(Redmine::Cwa.project_id)

    respond_to do |format|
      format.html
      format.json
    end
  end
end
