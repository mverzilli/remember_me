class LogsController < ApplicationController
  # GET /logs
  # GET /logs.xml
  def index
    @logs = Log.paginate(:page => params[:page], :per_page => 5).where(:schedule_id => params[:schedule_id])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @logs }
    end
  end
end
