class SchedulesController < AuthenticatedController

  def initialize
    super
    @show_breadcrum = true
    add_breadcrumb "Reminders", :schedules_path
  end

  # GET /schedules
  # GET /schedules.xml
  def index
    @schedules = Schedule.where(:user_id => current_user.id)

    @last_log = Log.find(:all, :conditions => ["schedule_id in (?)", @schedules.collect(&:id)]).sort_by(&:created_at).reverse.first rescue nil
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @schedules }
    end
  end
  # GET /schedules/1
  # GET /schedules/1.xml
  def show
    @schedule = Schedule.find(params[:id])
    add_breadcrumb @schedule.title, schedule_path(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @schedule }
    end
  end

  # GET /schedules/new
  # GET /schedules/new.xml
  def new
    add_breadcrumb "New Reminder", :new_schedule_path
    @schedule = FixedSchedule.new :timescale => "hours"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @schedule }
    end
  end

  # GET /schedules/1/edit
  def edit
    @schedule = Schedule.find(params[:id])
    add_breadcrumb @schedule.title, schedule_path(params[:id])
    add_breadcrumb "Settings", edit_schedule_path(params[:id])
    @schedule.sort_messages
  end

  # POST /schedules
  # POST /schedules.xml
  def create
    params[:schedule][:user] = current_user
    @schedule = params[:schedule][:type].constantize.new(params[:schedule])
    
    respond_to do |format|
      if @schedule.save
        format.html { redirect_to(schedule_url(@schedule), :notice => 'Schedule was successfully created.') }
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
    @schedule.type = params[:schedule][:type] unless params[:schedule][:type].blank?
    
    respond_to do |format|
      if @schedule.update_attributes(params[:schedule])
        format.html { redirect_to(schedule_url(@schedule), :notice => 'Schedule was successfully updated.') }
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
    else
      @schedule.notifySubscribers = false
    end
    @schedule.destroy

   respond_to do |format|
     format.html { redirect_to(schedules_url, :notice => 'Schedule was successfully deleted.') }
     format.xml  { head :ok }
   end
  end
end
