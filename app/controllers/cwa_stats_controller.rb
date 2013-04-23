class CwaStatsController < ApplicationController
  # GET /cwa_stats
  # GET /cwa_stats.json
  def index
    @project = Project.find(Redmine::Cwa.project_id)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cwa_stats }
    end
  end

  # GET /cwa_stats/1
  # GET /cwa_stats/1.json
  def show
    @cwa_stat = CwaStat.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cwa_stat }
    end
  end

  # GET /cwa_stats/new
  # GET /cwa_stats/new.json
  def new
    @cwa_stat = CwaStat.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cwa_stat }
    end
  end

  # GET /cwa_stats/1/edit
  def edit
    @cwa_stat = CwaStat.find(params[:id])
  end

  # POST /cwa_stats
  # POST /cwa_stats.json
  def create
    @cwa_stat = CwaStat.new(params[:cwa_stat])

    respond_to do |format|
      if @cwa_stat.save
        format.html { redirect_to @cwa_stat, notice: 'Cwa stat was successfully created.' }
        format.json { render json: @cwa_stat, status: :created, location: @cwa_stat }
      else
        format.html { render action: "new" }
        format.json { render json: @cwa_stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cwa_stats/1
  # PUT /cwa_stats/1.json
  def update
    @cwa_stat = CwaStat.find(params[:id])

    respond_to do |format|
      if @cwa_stat.update_attributes(params[:cwa_stat])
        format.html { redirect_to @cwa_stat, notice: 'Cwa stat was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cwa_stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cwa_stats/1
  # DELETE /cwa_stats/1.json
  def destroy
    @cwa_stat = CwaStat.find(params[:id])
    @cwa_stat.destroy

    respond_to do |format|
      format.html { redirect_to cwa_stats_url }
      format.json { head :no_content }
    end
  end
end
