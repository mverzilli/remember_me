class SchedulesController < AuthenticatedController
  # GET /schedules
  # GET /schedules.xml
  def index
    @schedules = Schedule.where(:user_id => current_user.id).all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @schedules }
    end
  end

  # GET /schedules/1
  # GET /schedules/1.xml
  def show
    @schedule = Schedule.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @schedule }
    end
  end

  # GET /schedules/new
  # GET /schedules/new.xml
  def new
    @schedule = Schedule.new :timescale => "hours"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @schedule }
    end
  end

  # GET /schedules/1/edit
  def edit
    @schedule = Schedule.find(params[:id])
    @schedule.sort_messages
  end

  # POST /schedules
  # POST /schedules.xml
  def create
    params[:schedule][:user] = current_user
    @schedule = params[:schedule][:type].constantize.new(params[:schedule])
    
    respond_to do |format|
      if @schedule.save  
        format.html { redirect_to(edit_schedule_url(@schedule), :notice => 'Schedule was successfully created.') }
        format.xml  { render :xml => @schedule, :status => :created, :location => @schedule }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @schedule.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /schedules/1
  # PUT /schedules/1.xml
  def update    
    @schedule = Schedule.find(params[:id])
    
    #Type needs to be manually set because it's protected, thus update_attributes doesn't affect it
    @schedule.type = params[@schedule.class.name.underscore][:type]
    
    respond_to do |format|
      if @schedule.update_attributes(params[@schedule.class.name.underscore])
        format.html { redirect_to(edit_schedule_url(@schedule), :notice => 'Schedule was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @schedule.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /schedules/1
  # DELETE /schedules/1.xml
  def destroy
    @schedule = Schedule.find(params[:id])
    if params[:notify] == "true"
      @schedule.notifySubscribers = true
    end
    @schedule.destroy

   respond_to do |format|
     format.html { redirect_to(schedules_url) }
     format.xml  { head :ok }
   end
  end
end
