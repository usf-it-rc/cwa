class CwaStatsController < ApplicationController
  # GET /cwa_stats
  # GET /cwa_stats.json
  
   helper CwaStatsApplicationHelper
   helper_method :sort_column, :sort_direction
  
     
  def index
    @project = Project.find(params[:project_id])
    
    # Get the stats for the table, set an initial sort order    
    @stats = CwaStat.order(sort_column + " " + sort_direction).group(:user_id).select('user_id, 
    sum(job_count) as job_count, sum(wallclock) as wallclock, sum(cputime) as cputime')
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @stats }
    end
  end

  def ganglia 
    @project = Project.find(params[:project_id])
    respond_to do |format|
      format.html
    end
  end
    

  private
  def sort_column
    CwaStat.column_names.include?(params[:sort]) ? params[:sort] : "user_id"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
