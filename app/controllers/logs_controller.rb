class LogsController < ApplicationController
  # GET /logs
  # GET /logs.xml
  def index
    @logs = Log.where(:schedule_id => params[:schedule_id]).page(params[:page]).per(5)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @logs }
    end
  end
end
