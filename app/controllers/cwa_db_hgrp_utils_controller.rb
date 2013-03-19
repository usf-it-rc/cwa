class CwaDbHgrpUtilsController < ApplicationController
  # GET /cwa_db_hgrp_utils
  # GET /cwa_db_hgrp_utils.json
  def index
    @cwa_db_hgrp_utils = CwaDbHgrpUtil.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cwa_db_hgrp_utils }
    end
  end

  # GET /cwa_db_hgrp_utils/1
  # GET /cwa_db_hgrp_utils/1.json
  def show
    @cwa_db_hgrp_util = CwaDbHgrpUtil.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cwa_db_hgrp_util }
    end
  end

  # GET /cwa_db_hgrp_utils/new
  # GET /cwa_db_hgrp_utils/new.json
  def new
    @cwa_db_hgrp_util = CwaDbHgrpUtil.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cwa_db_hgrp_util }
    end
  end

  # GET /cwa_db_hgrp_utils/1/edit
  def edit
    @cwa_db_hgrp_util = CwaDbHgrpUtil.find(params[:id])
  end

  # POST /cwa_db_hgrp_utils
  # POST /cwa_db_hgrp_utils.json
  def create
    @cwa_db_hgrp_util = CwaDbHgrpUtil.new(params[:cwa_db_hgrp_util])

    respond_to do |format|
      if @cwa_db_hgrp_util.save
        format.html { redirect_to @cwa_db_hgrp_util, notice: 'Cwa db hgrp util was successfully created.' }
        format.json { render json: @cwa_db_hgrp_util, status: :created, location: @cwa_db_hgrp_util }
      else
        format.html { render action: "new" }
        format.json { render json: @cwa_db_hgrp_util.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cwa_db_hgrp_utils/1
  # PUT /cwa_db_hgrp_utils/1.json
  def update
    @cwa_db_hgrp_util = CwaDbHgrpUtil.find(params[:id])

    respond_to do |format|
      if @cwa_db_hgrp_util.update_attributes(params[:cwa_db_hgrp_util])
        format.html { redirect_to @cwa_db_hgrp_util, notice: 'Cwa db hgrp util was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cwa_db_hgrp_util.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cwa_db_hgrp_utils/1
  # DELETE /cwa_db_hgrp_utils/1.json
  def destroy
    @cwa_db_hgrp_util = CwaDbHgrpUtil.find(params[:id])
    @cwa_db_hgrp_util.destroy

    respond_to do |format|
      format.html { redirect_to cwa_db_hgrp_utils_url }
      format.json { head :no_content }
    end
  end
end
