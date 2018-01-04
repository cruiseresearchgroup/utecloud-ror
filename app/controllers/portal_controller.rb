class PortalController < ApplicationController

  before_filter :authenticate_user

  def index
    redirect_to action: "experimentlist"
  end

  def sessionlist
    @allSessions = Session.all.order(:created_at)
  end

  def connections
    @session = Session.find_by_id(params[:id])
    if(@session.nil?)
      redirect_to action: "index"
      return
    end
    
    @sessionNumber = @session.session_number
    @sessionConnections = SessionConnection.where(:session_id => params[:id]).order(:connected_at)
  end

  def experimentlist
    @allExperiments = 
    [ 
      UteExperiment.where(
        :owner => session[:user_id], 
        :is_private => true, 
        :is_active => true
      ).where(
        :$or => [
          {:campaign_end_at.gte => Time.now.getutc.to_f},
          {:campaign_end_at => nil},
        ]
      ), 
      UteExperiment.where(
        :is_private => false, 
        :is_active => true
      ).where(
        :$or => [
          {:campaign_end_at.gte => Time.now.getutc.to_f},
          {:campaign_end_at => nil},
        ]
      )
    ].collect { |aoc| aoc.to_a}.flatten
    #@allExperiments = UteExperiment.collection.find({
    #"$or" => [
    #    { :owner => session[:user_id], :is_private => true },
    #    { :is_private => false, :is_active => true },
    #  ]
    #})
  end

  def experimentlistarchived
    @allExperiments = UteExperiment.where(:owner => session[:user_id], :is_private => true, :is_active => false).or(:is_private => false, :is_active => false)
  end

  def newexperiment
    flash[:error] = nil
    @experiment = UteExperiment.new 

    @experiment[:settings] = {
      :sensors => [
        {
          :name => "accelerometer"
        },
        {
          :name => "magnetometer"
        },
        {
          :name => "gyroscope"
        },
        {
          :name => "gps"
        },
        {
          :name => "noise_level"
        }, 
        {
          :name => "barometer"
        }, 
        {
          :name => "bluetooth"
        },
        {
          :name => "wifi"
        },
        {
          :name => "cell"
        }
      ]
    }

    @labelsetnames = Array.new
    @labelsetnames << 'Example'

    @labels = Array.new
    @labels << ['standing', 'sitting', 'walking', 'running']
  end

  def createnewexperiment
    @experiment_code = generateNewExperimentId(true) # public experiment

    while isExperimentIdAlreadyExist(@experiment_code) do
      @experiment_code = generateNewExperimentId(true) # public experiment
    end

    @experiment = UteExperiment.create!(
      talias: params[:experiment][:talias],
      title: params[:experiment][:title],
      text: params[:experiment][:text],
      experiment_code: @experiment_code,
      is_private: false,#experiment_params.is_private,
      is_cacheable: params[:experiment][:is_cacheable],
      is_active: true,
      created_on: Time.now.getutc.to_f,
      created_by: session[:user_id],
      owner: session[:user_id]
      )

    params[:ute_experiment][:settings][:version] = 1.0
    params[:ute_experiment][:settings][:maximumRecordingDuration] = 0

    @experiment.write_attribute(:settings, params[:ute_experiment][:settings])
    @experiment.save

    params[:labelnamesets] = params[:labelnamesets].collect(&:strip)
    totalCategory = params[:labels].keys.count #params[:labels].collect(&:strip)
    categories = params[:labels]

    #validate labels
    categorynameToSave = []
    labelsToSave = []
    if params[:labelnamesets].count == categories.count
      i = 0
      while i < totalCategory  do
        categories[i.to_s] = categories[i.to_s].collect(&:strip)
        labelset = categories[i.to_s].reject!{|a| a.nil? || a==""}
        if labelset.count > 0 
          labelsToSave << labelset
          categorynameToSave << params[:labelnamesets][i]
        end
        i += 1
      end
    end

    params[:labels] = labelsToSave
    params[:labelnamesets] = categorynameToSave
    

    #schema format
      #:schema => [
      #  { :set => params[:labels].reject!{|a| a.nil? || a==""}, :'is_nullable' => true, :'only_can_select_one' => true }
      #]

    

    if labelsToSave.count > 0 
      labelsettings = {
        :type => "interval",
        :schema => []
      };

      labelsToSave.each_with_index  do |labelset, i_labelset|
        labelsettings[:schema] << {
          :set_name => categorynameToSave[i_labelset],
          :set => labelset,
          :'is_nullable' => true, 
          :'only_can_select_one' => true
        }
      end
      
      @experiment.write_attribute(:'settings.label', labelsettings) 
    else 
      @experiment.write_attribute(:'settings.label', nil) 
    end

    #puts(@experiment)

    @experiment.save

    redirect_to portal_experimentlist_path
    return
  end 

  def purgeexperimentdata
    if (params.has_key?(:experiment_id) == false || params[:experiment_id].empty? ||
      (@experiment = UteExperiment.where(:id => params[:experiment_id], :owner => session[:user_id]).first) == nil)
      render json: { 
        'success' => false,
        'error' => 'no experiment id found'
      }.to_json
      return
    end

    # find the experiment data: session>connections>data[sensorinfos, intervallabels] 
    @experiment.ute_ex_sessions.each{ |session|
      session.delete
    }

    @experiment.ute_device_pairs.each{ |device_pair|
      device_pair.delete
    }

    render json: { 
      'success' => true
    }.to_json
  end

  def createnewdevicepair
    if (params.has_key?(:experiment_id) == false || params[:experiment_id].empty? ||
      (@experiment = UteExperiment.where(:id => params[:experiment_id]).first) == nil)
      render json: { 
        'success' => false,
        'error' => 'no experiment id found'
      }.to_json
      return
    end

    @devicepairotp = generateNewDevicePairOtp

    while isActiveDevicePairOtpAlreadyExist(@experiment.id, @devicepairotp) do
      @devicepairotp = generateNewDevicePairOtp
    end

    otp_lifetime = 15*60 #15 minutes for expiry time

    @experiment.ute_device_pairs.create!(
      otp: @devicepairotp,
      uuid: SecureRandom.uuid,
      is_active: true,
      expire_by: Time.now.getutc.to_f + otp_lifetime
    )

    render json: { 
      'success' => true,
      'otp' => @devicepairotp 
    }.to_json
  end

  #def paireddeviceslist
  #  if (params.has_key?(:id) == false || params[:id].empty? ||
  #    (@experiment = UteExperiment.where(:id => params[:id]).first) == nil)
  #    render json: { 'error' => 'no experiment id found' }.to_json
  #    return
  #  end
  #
  #  @paireddevices = @experiment.ute_device_pairs.where(:is_active => true)
  #  respond_to do |format|
  #    #format.html { render text: 'Paired Devices: <br/>' + { 'PairedDevices' => @paireddevices }.to_json  }
  #    format.html { render :paireddeviceslist  }
  #    format.json { 
  #      render json: torender
  #    }
  #  end
  #end

  def removepaireddevices
    if (
        params.has_key?(:experiment_id) == false || params[:experiment_id].empty? ||
        (@experiment = UteExperiment.where(:id => params[:experiment_id]).first) == nil ||
        params.has_key?(:pair_id) == false || params[:pair_id].empty? ||
        (@paired = @experiment.ute_device_pairs.where(:id => params[:pair_id]).first) == nil 
      )
      render json: { 
        'success' => true
      }.to_json 
      return
    end

    @paired.is_active = false
    @paired.save

    render json: { 
      'success' => true
    }.to_json 
  end

  def editexperiment
    if (params.has_key?(:id) == false || params[:id].empty? ||
      (@experiment = UteExperiment.where(:id => params[:id]).first) == nil)
      redirect_to portal_experimentlist_path
      return
    end

    @labels = Array.new
    @labelsetnames = Array.new
    @settings = @experiment.read_attribute(:settings)
    if @settings 
      @experiment[:settings] = @settings
      if @settings[:label] && @settings[:label][:type] == 'interval'
        @settings[:label][:schema].each_with_index do |labelset, i_labelset|
          labelset = @settings[:label][:schema][i_labelset][:set]
          puts(labelset)
          @labels << labelset
          @labelsetnames << @settings[:label][:schema][i_labelset][:set_name]
        end
      end
    end
  end

  def updateexperiment
    if (params.has_key?(:id) == false || params[:id].empty? ||
      (@experiment = UteExperiment.where(:id => params[:id]).first) == nil)
      redirect_to portal_experimentlist_path
      return
    end

    @experiment.update_attributes!(
      params[:ute_experiment].permit(
        :talias,
        :title, 
        :text, 
        :is_cacheable    
      )
    )

    #default values
    params[:ute_experiment][:settings][:version] = 1.0
    params[:ute_experiment][:settings][:maximumRecordingDuration] = 0

    @experiment.write_attribute(:settings, params[:ute_experiment][:settings])
    @experiment.save

    params[:labelnamesets] = params[:labelnamesets].collect(&:strip)
    totalCategory = params[:labels].keys.count #params[:labels].collect(&:strip)
    categories = params[:labels]

    #validate labels
    categorynameToSave = []
    labelsToSave = []
    if params[:labelnamesets].count == categories.count
      i = 0
      while i < totalCategory  do
        categories[i.to_s] = categories[i.to_s].collect(&:strip)
        labelset = categories[i.to_s].reject!{|a| a.nil? || a==""}
        if labelset.count > 0 
          labelsToSave << labelset
          categorynameToSave << params[:labelnamesets][i]
        end
        i += 1
      end
    end

    params[:labels] = labelsToSave
    params[:labelnamesets] = categorynameToSave
    

    #schema format
      #:schema => [
      #  { :set => params[:labels].reject!{|a| a.nil? || a==""}, :'is_nullable' => true, :'only_can_select_one' => true }
      #]

    

    if labelsToSave.count > 0 
      labelsettings = {
        :type => "interval",
        :schema => []
      };

      labelsToSave.each_with_index  do |labelset, i_labelset|
        labelsettings[:schema] << {
          :set_name => categorynameToSave[i_labelset],
          :set => labelset,
          :'is_nullable' => true, 
          :'only_can_select_one' => true
        }
      end
      
      @experiment.write_attribute(:'settings.label', labelsettings) 
    else 
      @experiment.write_attribute(:'settings.label', nil) 
    end
    
    #puts(@experiment)

    @experiment.save

    redirect_to portal_experimentlist_path
  end

  def removeexperiment 
    theExperiment = UteExperiment.where(:owner => session[:user_id]).find(params[:experiment_id])
    has_exsession = theExperiment.ute_ex_sessions.count > 0 ? true : false
    if has_exsession 
      theExperiment.is_active = false
      theExperiment.save!
    else
      theExperiment.delete
    end

    render json: { 
      'success' => true
    }.to_json 
  end

  def sessionconnectionlist 
    if (params.has_key?(:id) == false || params[:id].empty? ||
      (@experiment = UteExperiment.where(:id => params[:id]).first) == nil)
      redirect_to portal_experimentlist_path
      return
    end

    #@sessions = UteExSession.where(:'ute_experiment.id' => params[:id]).pluck(:session_code, :ute_ex_session_connections)
    @sessions = @experiment.ute_ex_sessions.order_by(:finished_at => 'asc')#.pluck(:session_code, :ute_ex_session_connections)

    #sessionlist = []
    #@sessions.each do |item|
    #  sessionlist.push({
    #    :session_code => item[:session_code],
    #    :connection_count => item[:ute_ex_session_connections].count
    #    })
    #end
    #
    #torender = { 
    #  'sessions' => sessionlist
    #}.to_json
    #
    #respond_to do |format|
    #  format.html { render text: 'Session list: <br/>' +  torender }
    #  format.json { 
    #    render json: torender
    #  }
    #
    #  return
    #end
  end

  def sessionconnectioninfos
    # inner join
    @allSessions = Session.joins(session_connections: :session_sensor_infos).order(:created_at)
  end

  def sensorInfos
    if (
        params.has_key?(:id) == false || params[:id].empty? ||
        (@experiment = UteExperiment.where(:id => params[:id]).first) == nil || 
        params.has_key?(:sessionId) == false || params[:sessionId].empty? ||
        (@session = @experiment.ute_ex_sessions.where(:id => params[:sessionId]).first) == nil
        params.has_key?(:connectionId) == false || params[:connectionId].empty? ||
        (@connection = @session.ute_ex_session_connections.where(:id => params[:connectionId]).first) == nil
      )

        respond_to do |format|
          format.html { render text: 'Unauthorized', :status => :unauthorized }
          format.json { 
            render :json => [], :status => :unauthorized 
          }
        end
      return
    end

    filename_to_download = "SensorData_" + (@connection.device_model || @connection.device_id ) + "_" + @session.session_code + ".csv"
    render_csv_sessioninfos(filename_to_download, @connection.ute_ex_session_sensorinfos)
  end

  def bluetoothInfos
    if (
        params.has_key?(:id) == false || params[:id].empty? ||
        (@experiment = UteExperiment.where(:id => params[:id]).first) == nil || 
        params.has_key?(:sessionId) == false || params[:sessionId].empty? ||
        (@session = @experiment.ute_ex_sessions.where(:id => params[:sessionId]).first) == nil
        params.has_key?(:connectionId) == false || params[:connectionId].empty? ||
        (@connection = @session.ute_ex_session_connections.where(:id => params[:connectionId]).first) == nil
      )

        respond_to do |format|
          format.html { render text: 'Unauthorized', :status => :unauthorized }
          format.json { 
            render :json => [], :status => :unauthorized 
          }
        end
      return
    end

    filename_to_download = "Bluetooth_" + (@connection.device_model || @connection.device_id ) + "_" + @session.session_code + ".csv"
    render_csv_bluetoothinfos(filename_to_download, @connection.ute_ex_session_bluetoothinfos)
  end

  def wifiInfos
    if (
        params.has_key?(:id) == false || params[:id].empty? ||
        (@experiment = UteExperiment.where(:id => params[:id]).first) == nil || 
        params.has_key?(:sessionId) == false || params[:sessionId].empty? ||
        (@session = @experiment.ute_ex_sessions.where(:id => params[:sessionId]).first) == nil
        params.has_key?(:connectionId) == false || params[:connectionId].empty? ||
        (@connection = @session.ute_ex_session_connections.where(:id => params[:connectionId]).first) == nil
      )

        respond_to do |format|
          format.html { render text: 'Unauthorized', :status => :unauthorized }
          format.json { 
            render :json => [], :status => :unauthorized 
          }
        end
      return
    end

    filename_to_download = "Wifi_" + (@connection.device_model || @connection.device_id ) + "_" + @session.session_code + ".csv"
    render_csv_wifiinfos(filename_to_download, @connection.ute_ex_session_wifiinfos)
  end

  def cellInfos 
    if (
        params.has_key?(:id) == false || params[:id].empty? ||
        (@experiment = UteExperiment.where(:id => params[:id]).first) == nil || 
        params.has_key?(:sessionId) == false || params[:sessionId].empty? ||
        (@session = @experiment.ute_ex_sessions.where(:id => params[:sessionId]).first) == nil
        params.has_key?(:connectionId) == false || params[:connectionId].empty? ||
        (@connection = @session.ute_ex_session_connections.where(:id => params[:connectionId]).first) == nil
      )

        respond_to do |format|
          format.html { render text: 'Unauthorized', :status => :unauthorized }
          format.json { 
            render :json => [], :status => :unauthorized 
          }
        end
      return
    end

    filename_to_download = "Cell_" + (@connection.device_model || @connection.device_id ) + "_" + @session.session_code + ".csv"
    render_csv_cellinfos(filename_to_download, @connection.ute_ex_session_cellinfos)
  end

  def intervalLabels
    if (
        params.has_key?(:id) == false || params[:id].empty? ||
        (@experiment = UteExperiment.where(:id => params[:id]).first) == nil || 
        params.has_key?(:sessionId) == false || params[:sessionId].empty? ||
        (@session = @experiment.ute_ex_sessions.where(:id => params[:sessionId]).first) == nil
        params.has_key?(:connectionId) == false || params[:connectionId].empty? ||
        (@connection = @session.ute_ex_session_connections.where(:id => params[:connectionId]).first) == nil
      )

        respond_to do |format|
          format.html { render text: 'Unauthorized', :status => :unauthorized }
          format.json { 
            render :json => [], :status => :unauthorized 
          }
        end
      return
    end
    
    filename_to_download = "IntervalLabel_" + (@connection.device_model || @connection.device_id ) + "_" + @session.session_code + ".csv"
    render_csv_intervallabels(filename_to_download, @connection.ute_ex_session_intervallabels)
  end

  def render_csv_sessioninfos(filename_to_download, sessionInfos)
    set_file_headers(filename_to_download)
    set_streaming_headers

    response.status = 200

    #setting the body to an enumerator, rails will iterate this enumerator
    self.response_body = csv_lines_sessioninfos(sessionInfos)
  end

  def render_csv_bluetoothinfos(filename_to_download, bluetoothInfos)
    set_file_headers(filename_to_download)
    set_streaming_headers

    response.status = 200

    #setting the body to an enumerator, rails will iterate this enumerator
    self.response_body = csv_lines_bluetoothinfos(bluetoothInfos)
  end

  def render_csv_wifiinfos(filename_to_download, wifiInfos)
    set_file_headers(filename_to_download)
    set_streaming_headers

    response.status = 200

    #setting the body to an enumerator, rails will iterate this enumerator
    self.response_body = csv_lines_wifiinfos(wifiInfos)
  end

  def render_csv_cellinfos(filename_to_download, cellInfos)
    set_file_headers(filename_to_download)
    set_streaming_headers

    response.status = 200

    #setting the body to an enumerator, rails will iterate this enumerator
    self.response_body = csv_lines_cellinfos(cellInfos)
  end

  def render_csv_intervallabels(filename_to_download, intervallabels)
    set_file_headers(filename_to_download)
    set_streaming_headers

    response.status = 200

    #setting the body to an enumerator, rails will iterate this enumerator
    self.response_body = csv_lines_intervallabels(intervallabels)
  end

  def set_file_headers(filename_to_download)
    #file_name = file_name
    
    response.headers['Content-Type'] ||= 'text/csv'
    response.headers['Content-Disposition'] = "attachment; filename=\"#{filename_to_download}\""
    response.headers['Content-Transfer-Encoding'] = 'binary'
    response.headers["Last-Modified"] = Time.now.ctime.to_s
    response.sending_file = true
  end


  def set_streaming_headers
    #nginx doc: Setting this to "no" will allow unbuffered responses suitable for Comet and HTTP streaming applications
    headers['X-Accel-Buffering'] = 'no'

    headers["Cache-Control"] ||= "no-cache"
    #headers["Transfer-Encoding"] = "chunked"
    headers.delete("Content-Length")
  end

  def csv_lines_sessioninfos(sessionInfos)
    Enumerator.new do |y|
      y << PortalHelper.sessioninfo_csv_header.to_s
      sessionInfos.each do |row|
        y << PortalHelper.sessioninfo_to_csv_row(row).to_s
      end
    end
  end

  def csv_lines_bluetoothinfos(bluetoothInfos)
    Enumerator.new do |y|
      y << PortalHelper.bluetoothinfo_csv_header.to_s
      bluetoothInfos.each do |row|
        y << PortalHelper.bluetoothinfo_to_csv_row(row).to_s
      end
    end
  end

  def csv_lines_wifiinfos(wifiInfos)
    Enumerator.new do |y|
      y << PortalHelper.wifiinfo_csv_header.to_s
      wifiInfos.each do |row|
        y << PortalHelper.wifiinfo_to_csv_row(row).to_s
      end
    end
  end

  def csv_lines_cellinfos(cellInfos)
    Enumerator.new do |y|
      y << PortalHelper.cellinfo_csv_header.to_s
      cellInfos.each do |row|
        y << PortalHelper.cellinfo_to_csv_row(row).to_s
      end
    end
  end

  def csv_lines_intervallabels(intervallabels)
    Enumerator.new do |y|
      y << PortalHelper.intervallabel_csv_header.to_s
      intervallabels.each do |row|
        y << PortalHelper.intervallabel_to_csv_row(row).to_s
      end
    end
  end

  # PRIVATE class methods 
  private

  def isExperimentIdAlreadyExist(experiment_code)
    if(experiment_code == nil)
      return false
    end

    # check if session ID already exist in DB. 
    return UteExperiment.where(:experiment_code => experiment_code, :is_active => true).exists?
  end

  def generateNewExperimentId(ispublic)
      return (ispublic ?  "PUB" : "PRV") + 'EX' + (1 + Random.rand(1000000000)).to_s
  end

  def isActiveDevicePairOtpAlreadyExist(experiment_id, devicepairotp)
    if(experiment_id == nil)
      return true
    end

    # check if session ID already exist in DB. 
    return UteDevicePair.where(
      :is_active => true, 
      :'ute_experiment._id' => experiment_id, 
      :otp => devicepairotp, 
      :expire_by.gte => Time.now.getutc.to_f).exists?
  end

  def generateNewDevicePairOtp
    # hardcoded OTP settings 
    otp_length = 5

    otp = ''
    for i in 0..(otp_length-1)
      otp += generateSingleCharForOtp
    end

    return otp
  end

  def generateSingleCharForOtp
    return Random.rand(10).to_s
  end

end
