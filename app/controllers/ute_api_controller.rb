class UteApiController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [
    :generateDeviceUuid, 
    :createNewSessionId, 
    :connectToSession, 
    :submitSessionServiceMotions, 
    :uploadSessionSensors, 
    :deleteSessionConnection, 
    :isSessionStillActive, 
    :submitSessionSurvey, 
    :mobileappAndroidVersion, 
    :mobileappAndroidDownload,

    :experimentList,
    :getExperimentDetails,
    :sessionList,
    :pairDevice,
    :unpairDevice,
    :createSession,
    :connectSession,
    :submitSessionInfos,
    :submitSessionBluetooths,
    :submitSessionWifis,
    :submitSessionCells,
    :submitSessionLabels,
    :closeSessionConnection
  ]

  OTP_DEVICE_PAIR_CONN_LIFETIME = 24*60*60 #1 day for expiry time
  
  def index
    redirect_to(controller: "portal", action: "experimentlist")
  end

  def mobileappAndroidVersion
    render json: { 'version' => '1.0' }.to_json 
  end

  def mobileappAndroidDownload
    headers['Content-Type'] = 'application/vnd.android.package-archive'
    send_file("app/assets/mobileapp/utecollection.apk",
              filename: "utecollection.apk",
              type: 'application/vnd.android.package-archive')
  end

  def generateDeviceUuid
    device_uuid = SecureRandom.uuid
    respond_to do |format|
      format.html { render text: 'Device UUID: <br/>' + device_uuid }
      format.json { 
        render json: { 'uuid' => device_uuid }.to_json 
      }
    end
  end

  # GET - list active sessions. 
  def experimentList
    @allExperiments = UteExperiment.where(:is_private => false, :is_active => true).where(
      :$or => [
        {:campaign_end_at.gte => Time.now.getutc.to_f},
        {:campaign_end_at => nil},
      ]
    )#.pluck(:experiment_code, :talias)
    #[ 
    #  #UteExperiment.where(:owner => session[:user_id], :is_private => true, :is_active => true), #no personalisation yet implemented
    #  UteExperiment.where(:is_private => false, :is_active => true).pluck(:experiment_code, :talias)
    #].collect { |aoc| aoc.to_a}.flatten
    #@sessionlist = Session.where(:is_active => true).map{ |x| 
    #  { 
    #    :session_number => x.session_number, 
    #    :id => x.id, 
    #    :isexposed => true 
    #  } 
    #}
    @experimentlist = []
    @allExperiments.each do |experiment| 
      @experimentlist << {
        experiment_id: experiment.experiment_code,
        is_cacheable: experiment.is_cacheable,
        talias: experiment.talias,
        title: experiment.title,
        description: experiment.text
      }
    end
    respond_to do |format|
      format.html { render text: 'Experiment list: <br/>' + { 'experiments' => @experimentlist }.to_json  }
      format.json { 
        render json: { 'experiments' => @experimentlist }.to_json 
      }
    end
  end

  # GET - get details of experiment. 
  def getExperimentDetails
    @experiment = UteExperiment.where(:experiment_code => params[:experiment_id], :is_active => true).first
    if @experiment
      response = { 'title' => @experiment.title, 'description' => @experiment.text }.to_json
      respond_to do |format|
        format.html { render text: 'Experiment details: <br/>' + response }
        format.json { 
          render json: response 
        }
      end
    else
      response = nil.to_json
      respond_to do |format|
        format.html { render text: 'Experiment details: <br/>' + response }
        format.json { 
          render json: response 
        }
      end
    end
  end

  # GET - list active sessions. 
  def sessionList
    if (
        params.has_key?(:experiment_id) == false || params[:experiment_id].empty? ||
        (@experiment = UteExperiment.where(:experiment_code => params[:experiment_id], :is_active => true).first) == nil
      ) 
      respond_to do |format|
        format.html { render text: 'Unauthorized', :status => :unauthorized }
        format.json { 
          render :json => [], :status => :unauthorized 
        }
      end
      return
    end

    @sessionlist = @experiment.ute_ex_sessions.where(:is_active => true).pluck(:session_code)
    #[ 
    #  UteExSession.where(:'ute_experiment.experiment_code' => params[:experiment_code], :is_active => true).pluck(:session_code)
    #].collect { |aoc| aoc.to_a}.flatten

    respond_to do |format|
      format.html { render text: 'Session list: <br/>' + { 'sessions' => @sessionlist }.to_json  }
      format.json { 
        render json: { 'sessions' => @sessionlist }.to_json 
      }
    end
  end

  # POST - Pair device
  def pairDevice
    # not having valid device id or device type. 
    @deviceType = nil
    if (
        params.has_key?(:did) == false || params[:did].empty? || 
        params.has_key?(:dtype) == false || params[:dtype].empty? ||
        (@deviceType = DeviceType.where(name: params[:dtype]).first) == nil || 
        params.has_key?(:experiment_id) == false || params[:experiment_id].empty? ||
        (@experiment = UteExperiment.where(:experiment_code => params[:experiment_id], :is_cacheable => true, :is_active => true).first) == nil ||
        params.has_key?(:otp) == false || params[:otp].empty? ||
        (@otptopair = @experiment.ute_device_pairs.where(:otp => params[:otp], :is_active => true, :expire_by.gte => Time.now.getutc.to_f).first) == nil 
      ) 
      respond_to do |format|
        format.html { render text: 'Unauthorized', :status => :unauthorized }
        format.json { 
          render :json => [], :status => :unauthorized 
        }
      end
      return
    end

    @deviceId = params[:did]
    @otptopair.ute_device_pair_requesters.create!(
      device_id: @deviceId,
      device_model: params[:model],
      device_type: @deviceType.id,
      is_active: true
    )

    respond_to do |format|

      format.html { render text: 'Your Pairing has been activated for: ' + @otptopair.otp }
      format.json { 
        #{'foo' => 'bar'}.to_json
        # render :json => '{ "\"sessionId\"": "TEST001" }' 
        render json: { 
          'status' => 'OK', 
          'uid' => @otptopair.uuid, 
          'server_time' => Time.now.getutc.to_f,
          'settings' => @experiment.read_attribute(:settings),
          'campaign_end_at' => @experiment.campaign_end_at
        }.to_json
      }
    end
  end

  # POST - unpair device
  def unpairDevice
    # not having valid device id or device type. 
    @deviceType = nil
    if (
        params.has_key?(:did) == false || params[:did].empty? || 
        params.has_key?(:dtype) == false || params[:dtype].empty? ||
        (@deviceType = DeviceType.where(name: params[:dtype]).first) == nil || 
        params.has_key?(:experiment_id) == false || params[:experiment_id].empty? ||
        (@experiment = UteExperiment.where(:experiment_code => params[:experiment_id], :is_active => true).first) == nil ||
        params.has_key?(:uid) == false || params[:uid].empty? ||
        (@otptopair = @experiment.ute_device_pairs.where(:uuid => params[:uid], :is_active => true).first) == nil 
      ) 
      respond_to do |format|
        format.html { render text: 'Unauthorized', :status => :unauthorized }
        format.json { 
          render json: { 'status' => 'OK' }.to_json
        }
      end
      return
    end

    @deviceId = params[:did]

    @associatedDevices = @otptopair.ute_device_pair_requesters.where(:device_id => @deviceId, :is_active => true)
    @associatedDevices.each do |associatedDevice|
      associatedDevice.is_active = false
      associatedDevice.save
    end

    respond_to do |format|

      format.html { render text: 'Your request for device unpairing has been successfull: ' + @otptopair.otp }
      format.json { 
        #{'foo' => 'bar'}.to_json
        # render :json => '{ "\"sessionId\"": "TEST001" }' 
        render json: { 'status' => 'OK' }.to_json
      }
    end
  end

  def experimentSettings
    # not having valid device id or device type. 
    @deviceType = nil
    if (
        params.has_key?(:did) == false || params[:did].empty? || 
        params.has_key?(:dtype) == false || params[:dtype].empty? ||
        (@deviceType = DeviceType.where(name: params[:dtype]).first) == nil || 
        params.has_key?(:experiment_code) == false || params[:experiment_id].empty? ||
        (@experiment = UteExperiment.where(:experiment_code => params[:experiment_id], :is_active => true).first) == nil
      ) 
      respond_to do |format|
        format.html { render text: 'Unauthorized', :status => :unauthorized }
        format.json { 
          render :json => [], :status => :unauthorized 
        }
      end
      return
    end
  end

  #POST - create a new session
  def createSession
    # not having valid device id or device type. 
    @deviceType = nil
    if (
        params.has_key?(:did) == false || params[:did].empty? || 
        params.has_key?(:dtype) == false || params[:dtype].empty? ||
        (@deviceType = DeviceType.where(name: params[:dtype]).first) == nil || 
        params.has_key?(:experiment_id) == false || params[:experiment_id].empty? ||
        (@experiment = UteExperiment.where(:experiment_code => params[:experiment_id], :is_active => true).first) == nil
      ) 
      respond_to do |format|
        format.html { render text: 'Unauthorized', :status => :unauthorized }
        format.json { 
          render :json => [], :status => :unauthorized 
        }
      end
      return
    end

    @sessionId = generateNewSessionId

    while isSessionIdAlreadyExist(@experiment.experiment_code, @sessionId) do
      @sessionId = generateNewSessionId
    end

    #create sessionid
    @deviceId = params[:did]
    puts('device id:'+@deviceId)
    begin
      @newsession = @experiment.ute_ex_sessions.create!(
        session_code: @sessionId,
        is_active: true,
        initiated_by_device_id: @deviceId,
        is_created_offline: false
      )
    rescue => e
      puts(e.message)
    end

    puts('creating new session object')
    if @newsession
      @newsession.ute_ex_session_connections.create!(device_id: @deviceId, device_model: params["model"], device_type: @deviceType.id, is_active: true, connected_at: Time.now.getutc.to_f)
      
      #torender = { 
      #  'sessionId' => @sessionId,
      #  'created_at' => @newsession.created_at.to_time.to_f,
      #  'settings' => {
      #    'version' => 1.0,
      #    'maximumRecordingDuration' => 0,
      #    'sensors' => [
      #      { :name => 'accelerometer', :freq => 50 },
      #      { :name => 'magnetometer', :freq => 50 },
      #      { :name => 'gyroscope', :freq => 50 },
      #      { :name => 'gps', :freq => 1 }
      #    ],
      #    'label' => {
      #          'type' => 'interval',
      #          'schema' => [
      #            { 'set' => [ 'standing', 'sitting', 'walking', 'running' ], 'is_nullable' => true, 'only_can_select_one' => true }
      #          ]
      #        }
      #  }
      #}.to_json 

      @settings = @experiment.read_attribute(:settings)

      torender = { 
            'status' => 'OK',
            'sessionId' => @newsession.session_code,
            'created_at' => @newsession.created_at.to_time.to_f,
            'settings' => @settings
        }.to_json 

      respond_to do |format|

        format.html { render text: 'Your Session: ' + @sessionId + ', json details: <br/>' + torender }
        format.json { 
          #{'foo' => 'bar'}.to_json
          # render :json => '{ "\"sessionId\"": "TEST001" }' 
          render json: torender
        }
      end
    else 
      # reply with invalid session created
      respond_to do |format|
        format.html { render text: 'There is an error creating a new session.' }
        format.json { 
          #{'foo' => 'bar'}.to_json
          # render :json => '{ "\"sessionId\"": "TEST001" }' 
          render json: { 'error' => 'Error creating new session' }.to_json 
        }
      end
    end
  end

  # POST - connect to a current active session. 
  def connectSession
    # not having valid device id or session number or device type. 
    if (params.has_key?(:session_id) == false || params[:session_id].empty? ||
      params.has_key?(:did) == false || params[:did].empty? || 
      params.has_key?(:dtype) == false || params[:dtype].empty? ||
      params.has_key?(:experiment_id) == false || params[:experiment_id].empty? ||
      (@experiment = UteExperiment.where(:experiment_code => params[:experiment_id]).first) == nil ||
      (@deviceType = DeviceType.where(name: params[:dtype]).first) == nil ||
      (@session = @experiment.ute_ex_sessions.where(:session_code => params[:session_id], :is_active => true).first) == nil)
      respond_to do |format|
        format.html { render text: 'Unauthorized', :status => :unauthorized }
        format.json { 
          render :json => [], :status => :unauthorized 
        }
      end
      return
    end

    @deviceId = params[:did]
    @sessionconnection = @session.ute_ex_session_connections.where(:device_id => @deviceId, :device_type => @deviceType.id).first
    if(@sessionconnection == nil)
      @sessionconnection = @session.ute_ex_session_connections.create(device_id: @deviceId, device_model: params["model"], device_type: @deviceType.id, is_active: true, connected_at: Time.now.getutc.to_f);
    else
      @sessionconnection.is_active = true
      @sessionconnection.connected_at = Time.now.getutc.to_f
      @sessionconnection.save!
    end
    
    #torender = { 
    #        'status' => 'OK',
    #        'created_at' => @session.created_at.to_time.to_f,
    #        'settings' => {
    #          'version' => 1.0,
    #          'maximumRecordingDuration' => 0,
    #          'sensors' => [
    #            { :name => 'accelerometer', :freq => 50 },
    #            { :name => 'magnetometer', :freq => 50 },
    #            { :name => 'gyroscope', :freq => 50 },
    #            { :name => 'gps', :freq => 1 }
    #          ],
    #          'label' => {
    #            'type' => 'interval',
    #            'schema' => [
    #              { 'set' => [ 'standing', 'sitting', 'walking', 'running' ], 'is_nullable' => true, 'only_can_select_one' => true }
    #            ]
    #          }
    #        }
    #    }.to_json 
    torender = { 
            'status' => 'OK',
            'created_at' => @sessionconnection.connected_at,
            'settings' => @experiment.read_attribute(:settings)
        }.to_json 
    respond_to do |format|
      format.html { render text: 'Session Status: Connected<br/>' + torender }
      format.json { 
        render json: torender
      }
    end
  end

  # POST - submit data for session sensor data
  def submitSessionInfos
    # check if data submission is offline
    is_offline_sensor_data_collection = false

    # not having valid device id or device type. 
    if params.has_key?(:uid) == true && !params[:uid].empty?
      @deviceType = nil
      if (
          params.has_key?(:did) == false || params[:did].empty? || 
          params.has_key?(:dtype) == false || params[:dtype].empty? ||
          (@deviceType = DeviceType.where(name: params[:dtype]).first) == nil || 
          params.has_key?(:experiment_id) == false || params[:experiment_id].empty? ||
          (@experiment = UteExperiment.where(:experiment_code => params[:experiment_id], :is_active => true).first) == nil
        ) 
        respond_to do |format|
          format.html { render text: 'Unauthorized', :status => :unauthorized }
          format.json { 
            render :json => [], :status => :unauthorized 
          }
        end
        return
      end

      if (
        params.has_key?(:sensor_infos) == false  || params[:sensor_infos].empty? || 
        params[:sensor_infos].kind_of?(Array) == false || params[:sensor_infos].count == 0
      )
        render json: { 'status' => 'OK' }.to_json
      end

      # check device pairing. 
      @deviceId = params[:did]
      if isPairedDeviceValid(@deviceId, params[:uid]) == false
        respond_to do |format|
          format.html { render text: 'Unauthorized', :status => :unauthorized }
          format.json { 
            render :json => [], :status => :unauthorized 
          }
        end
        return
      end

      needToCreateSession = false
      if params.has_key?(:is_initiator) && params[:is_initiator] == true
        needToCreateSession = true
      else
        # check if devicepairconnotp is not expired yet
        @devicepairconnections = @devicepairs.ute_device_pair_connections.where(
                                                                                :expire_by.gte => Time.now.getutc.to_f, 
                                                                                :is_active => true
                                                                              )
        firststartdate = params[:sensor_infos][0][:t]
        @devicepairconnections.each do |devicepairconnection|
          si = devicepairconnection.ute_ex_session
          unless si.nil?
            if firststartdate > si.range_start_at && firststartdate < si.range_end_at 
              #found the paired connection
              @devicepairconnection = devicepairconnection
              @session = @devicepairconnection.ute_ex_session
              break
            end
          end
        end

        if @devicepairconnection == nil && @session == nil 
          #session to pair is not found
          render json: { 'status' => 'FAILED', 'code' => 404 }.to_json
          return
        end
      end

      if needToCreateSession 
        # create new session
        @sessionId = generateNewSessionId

        while isSessionIdAlreadyExist(@experiment.experiment_code, @sessionId) do
          @sessionId = generateNewSessionId
        end

        @session = @experiment.ute_ex_sessions.create!(
            session_code: @sessionId,
            is_active: true,
            initiated_by_device_id: @deviceId,
            is_created_offline: true
          )
      end

      if @session
        @sessionConnection = @session.ute_ex_session_connections.create!(device_id: @deviceId, device_model: params["model"], device_type: @deviceType.id, is_active: true, connected_at: params[:sensor_infos][0][:t])
        
        @devicepairconnotp = generateNewDevicePairConnOtp

        while isActiveDevicePairConnOtpAlreadyExist(@devicepairs, @devicepairconnotp) do
          @devicepairconnotp = generateNewDevicePairConnOtp
        end

        dpc = @devicepairs.ute_device_pair_connections.new(
            is_active: true,
            otp: @devicepairconnotp,
            expire_by: Time.now.getutc.to_f + OTP_DEVICE_PAIR_CONN_LIFETIME, 
            ute_ex_session: @session
          )
        dpc.save! 

        @session.ute_device_pair_connection = dpc
        @session.save!

        is_offline_sensor_data_collection = true
      end
    end 

    if isDataSubmissionInvalidForExpAndSession(request, params) 
        respond_to do |format|
          format.html { render text: 'Unauthorized', :status => :unauthorized }
          format.json { 
            render :json => [], :status => :unauthorized 
          }
        end
      return
    end

    begin
      if params.has_key?(:sensor_infos) && params[:sensor_infos].empty? == false
        UteDataSubmissionService.delay.handlesensorinfos(@session, @sessionConnection, params)
      end
    rescue => e
      puts(e.message)
      raise 'an error has occured'
      #puts(e.backtrace.join("\n"))
    end

    #begin
    #  if params.has_key?(:sensor_infos) && params[:sensor_infos].empty? == false
    #    puts('receiving first item: ' + params[:sensor_infos][0][:t].to_s)
    #  end
    #rescue => e
    #  puts('TRY TO RESCUE')
    #
    #  puts(e.message)
    #  raise 'an error has occured'
    #  #puts(e.backtrace.join("\n"))
    #end

    if @devicepairconnection != nil && is_offline_sensor_data_collection 
      #otp needs to be renewed
      @devicepairconnection.update_attributes(
        expire_by: Time.now.getutc.to_f + OTP_DEVICE_PAIR_CONN_LIFETIME
      )
    end    
    
    if is_offline_sensor_data_collection
      render json: { 'status' => 'OK', 'otp' => @devicepairconnotp, 'session_id' => @session.session_code }.to_json
    else
      render json: { 'status' => 'OK' }.to_json
    end
  end

  # POST - submit data for session bluetooth data
  def submitSessionBluetooths
    # check if data submission is offline
    is_offline_sensor_data_collection = false

    # not having valid device id or device type. 
    if params.has_key?(:uid) == true && !params[:uid].empty?
      @deviceType = nil
      if (
          params.has_key?(:did) == false || params[:did].empty? || 
          params.has_key?(:dtype) == false || params[:dtype].empty? ||
          (@deviceType = DeviceType.where(name: params[:dtype]).first) == nil || 
          params.has_key?(:experiment_id) == false || params[:experiment_id].empty? ||
          (@experiment = UteExperiment.where(:experiment_code => params[:experiment_id], :is_active => true).first) == nil
        ) 
        respond_to do |format|
          format.html { render text: 'Unauthorized', :status => :unauthorized }
          format.json { 
            render :json => [], :status => :unauthorized 
          }
        end
        return
      end

      if (
        params.has_key?(:bluetooth_infos) == false  || params[:bluetooth_infos].empty? || 
        params[:bluetooth_infos].kind_of?(Array) == false || params[:bluetooth_infos].count == 0
      )
        render json: { 'status' => 'OK' }.to_json
      end

      # check device pairing. 
      @deviceId = params[:did]
      if isPairedDeviceValid(@deviceId, params[:uid]) == false
        respond_to do |format|
          format.html { render text: 'Unauthorized', :status => :unauthorized }
          format.json { 
            render :json => [], :status => :unauthorized 
          }
        end
        return
      end

      needToCreateSession = false
      if params.has_key?(:is_initiator) && params[:is_initiator] == true
        needToCreateSession = true
      else
        # check if devicepairconnotp is not expired yet
        @devicepairconnections = @devicepairs.ute_device_pair_connections.where(
                                                                                :expire_by.gte => Time.now.getutc.to_f, 
                                                                                :is_active => true
                                                                              )
        firststartdate = params[:bluetooth_infos][0][:t]
        @devicepairconnections.each do |devicepairconnection|
          si = devicepairconnection.ute_ex_session
          unless si.nil?
            if firststartdate > si.range_start_at && firststartdate < si.range_end_at 
              #found the paired connection
              @devicepairconnection = devicepairconnection
              @session = @devicepairconnection.ute_ex_session
              break
            end
          end
        end

        if @devicepairconnection == nil && @session == nil 
          #session to pair is not found
          render json: { 'status' => 'FAILED', 'code' => 404 }.to_json
          return
        end
      end

      if needToCreateSession 
        # create new session
        @sessionId = generateNewSessionId

        while isSessionIdAlreadyExist(@experiment.experiment_code, @sessionId) do
          @sessionId = generateNewSessionId
        end

        @session = @experiment.ute_ex_sessions.create!(
            session_code: @sessionId,
            is_active: true,
            initiated_by_device_id: @deviceId,
            is_created_offline: true
          )
      end

      if @session
        @sessionConnection = @session.ute_ex_session_connections.create!(device_id: @deviceId, device_model: params["model"], device_type: @deviceType.id, is_active: true, connected_at: params[:sensor_infos][0][:t])
        
        @devicepairconnotp = generateNewDevicePairConnOtp

        while isActiveDevicePairConnOtpAlreadyExist(@devicepairs, @devicepairconnotp) do
          @devicepairconnotp = generateNewDevicePairConnOtp
        end

        dpc = @devicepairs.ute_device_pair_connections.new(
            is_active: true,
            otp: @devicepairconnotp,
            expire_by: Time.now.getutc.to_f + OTP_DEVICE_PAIR_CONN_LIFETIME, 
            ute_ex_session: @session
          )
        dpc.save! 

        @session.ute_device_pair_connection = dpc
        @session.save!

        is_offline_sensor_data_collection = true
      end
    end 

    if isDataSubmissionInvalidForExpAndSession(request, params) 
        respond_to do |format|
          format.html { render text: 'Unauthorized', :status => :unauthorized }
          format.json { 
            render :json => [], :status => :unauthorized 
          }
        end
      return
    end

    begin
      if params.has_key?(:bluetooth_infos) && params[:bluetooth_infos].empty? == false
        UteDataSubmissionService.delay.handlesensorbluetooths(@session, @sessionConnection, params)
      end
    rescue => e
      puts(e.message)
      raise 'an error has occured'
      #puts(e.backtrace.join("\n"))
    end

    if @devicepairconnection != nil && is_offline_sensor_data_collection 
      #otp needs to be renewed
      @devicepairconnection.update_attributes(
        expire_by: Time.now.getutc.to_f + OTP_DEVICE_PAIR_CONN_LIFETIME
      )
    end    
    
    if is_offline_sensor_data_collection
      render json: { 'status' => 'OK', 'otp' => @devicepairconnotp, 'session_id' => @session.session_code }.to_json
    else
      render json: { 'status' => 'OK' }.to_json
    end
  end

  # POST - submit data for session wifi data
  def submitSessionWifis
    # check if data submission is offline
    is_offline_sensor_data_collection = false

    # not having valid device id or device type. 
    if params.has_key?(:uid) == true && !params[:uid].empty?
      @deviceType = nil
      if (
          params.has_key?(:did) == false || params[:did].empty? || 
          params.has_key?(:dtype) == false || params[:dtype].empty? ||
          (@deviceType = DeviceType.where(name: params[:dtype]).first) == nil || 
          params.has_key?(:experiment_id) == false || params[:experiment_id].empty? ||
          (@experiment = UteExperiment.where(:experiment_code => params[:experiment_id], :is_active => true).first) == nil
        ) 
        respond_to do |format|
          format.html { render text: 'Unauthorized', :status => :unauthorized }
          format.json { 
            render :json => [], :status => :unauthorized 
          }
        end
        return
      end

      if (
        params.has_key?(:wifi_infos) == false  || params[:wifi_infos].empty? || 
        params[:wifi_infos].kind_of?(Array) == false || params[:wifi_infos].count == 0
      )
        render json: { 'status' => 'OK' }.to_json
      end

      # check device pairing. 
      @deviceId = params[:did]
      if isPairedDeviceValid(@deviceId, params[:uid]) == false
        respond_to do |format|
          format.html { render text: 'Unauthorized', :status => :unauthorized }
          format.json { 
            render :json => [], :status => :unauthorized 
          }
        end
        return
      end

      needToCreateSession = false
      if params.has_key?(:is_initiator) && params[:is_initiator] == true
        needToCreateSession = true
      else
        # check if devicepairconnotp is not expired yet
        @devicepairconnections = @devicepairs.ute_device_pair_connections.where(
                                                                                :expire_by.gte => Time.now.getutc.to_f, 
                                                                                :is_active => true
                                                                              )
        firststartdate = params[:wifi_infos][0][:t]
        @devicepairconnections.each do |devicepairconnection|
          si = devicepairconnection.ute_ex_session
          unless si.nil?
            if firststartdate > si.range_start_at && firststartdate < si.range_end_at 
              #found the paired connection
              @devicepairconnection = devicepairconnection
              @session = @devicepairconnection.ute_ex_session
              break
            end
          end
        end

        if @devicepairconnection == nil && @session == nil 
          #session to pair is not found
          render json: { 'status' => 'FAILED', 'code' => 404 }.to_json
          return
        end
      end

      if needToCreateSession 
        # create new session
        @sessionId = generateNewSessionId

        while isSessionIdAlreadyExist(@experiment.experiment_code, @sessionId) do
          @sessionId = generateNewSessionId
        end

        @session = @experiment.ute_ex_sessions.create!(
            session_code: @sessionId,
            is_active: true,
            initiated_by_device_id: @deviceId,
            is_created_offline: true
          )
      end

      if @session
        @sessionConnection = @session.ute_ex_session_connections.create!(device_id: @deviceId, device_model: params["model"], device_type: @deviceType.id, is_active: true, connected_at: params[:sensor_infos][0][:t])
        
        @devicepairconnotp = generateNewDevicePairConnOtp

        while isActiveDevicePairConnOtpAlreadyExist(@devicepairs, @devicepairconnotp) do
          @devicepairconnotp = generateNewDevicePairConnOtp
        end

        dpc = @devicepairs.ute_device_pair_connections.new(
            is_active: true,
            otp: @devicepairconnotp,
            expire_by: Time.now.getutc.to_f + OTP_DEVICE_PAIR_CONN_LIFETIME, 
            ute_ex_session: @session
          )
        dpc.save! 

        @session.ute_device_pair_connection = dpc
        @session.save!

        is_offline_sensor_data_collection = true
      end
    end 

    if isDataSubmissionInvalidForExpAndSession(request, params) 
        respond_to do |format|
          format.html { render text: 'Unauthorized', :status => :unauthorized }
          format.json { 
            render :json => [], :status => :unauthorized 
          }
        end
      return
    end

    begin
      if params.has_key?(:wifi_infos) && params[:wifi_infos].empty? == false
        UteDataSubmissionService.delay.handlesensorwifis(@session, @sessionConnection, params)
      end
    rescue => e
      puts(e.message)
      raise 'an error has occured'
      #puts(e.backtrace.join("\n"))
    end

    if @devicepairconnection != nil && is_offline_sensor_data_collection 
      #otp needs to be renewed
      @devicepairconnection.update_attributes(
        expire_by: Time.now.getutc.to_f + OTP_DEVICE_PAIR_CONN_LIFETIME
      )
    end    
    
    if is_offline_sensor_data_collection
      render json: { 'status' => 'OK', 'otp' => @devicepairconnotp, 'session_id' => @session.session_code }.to_json
    else
      render json: { 'status' => 'OK' }.to_json
    end
  end

  # POST - submitSessionCells
  def submitSessionCells
    # check if data submission is offline
    is_offline_sensor_data_collection = false

    # not having valid device id or device type. 
    if params.has_key?(:uid) == true && !params[:uid].empty?
      @deviceType = nil
      if (
          params.has_key?(:did) == false || params[:did].empty? || 
          params.has_key?(:dtype) == false || params[:dtype].empty? ||
          (@deviceType = DeviceType.where(name: params[:dtype]).first) == nil || 
          params.has_key?(:experiment_id) == false || params[:experiment_id].empty? ||
          (@experiment = UteExperiment.where(:experiment_code => params[:experiment_id], :is_active => true).first) == nil
        ) 
        respond_to do |format|
          format.html { render text: 'Unauthorized', :status => :unauthorized }
          format.json { 
            render :json => [], :status => :unauthorized 
          }
        end
        return
      end

      if (
        params.has_key?(:cell_infos) == false  || params[:cell_infos].empty? || 
        params[:cell_infos].kind_of?(Array) == false || params[:cell_infos].count == 0
      )
        render json: { 'status' => 'OK' }.to_json
      end

      # check device pairing. 
      @deviceId = params[:did]
      if isPairedDeviceValid(@deviceId, params[:uid]) == false
        respond_to do |format|
          format.html { render text: 'Unauthorized', :status => :unauthorized }
          format.json { 
            render :json => [], :status => :unauthorized 
          }
        end
        return
      end

      needToCreateSession = false
      if params.has_key?(:is_initiator) && params[:is_initiator] == true
        needToCreateSession = true
      else
        # check if devicepairconnotp is not expired yet
        @devicepairconnections = @devicepairs.ute_device_pair_connections.where(
                                                                                :expire_by.gte => Time.now.getutc.to_f, 
                                                                                :is_active => true
                                                                              )
        firststartdate = params[:cell_infos][0][:t]
        @devicepairconnections.each do |devicepairconnection|
          si = devicepairconnection.ute_ex_session
          unless si.nil?
            if firststartdate > si.range_start_at && firststartdate < si.range_end_at 
              #found the paired connection
              @devicepairconnection = devicepairconnection
              @session = @devicepairconnection.ute_ex_session
              break
            end
          end
        end

        if @devicepairconnection == nil && @session == nil 
          #session to pair is not found
          render json: { 'status' => 'FAILED', 'code' => 404 }.to_json
          return
        end
      end

      if needToCreateSession 
        # create new session
        @sessionId = generateNewSessionId

        while isSessionIdAlreadyExist(@experiment.experiment_code, @sessionId) do
          @sessionId = generateNewSessionId
        end

        @session = @experiment.ute_ex_sessions.create!(
            session_code: @sessionId,
            is_active: true,
            initiated_by_device_id: @deviceId,
            is_created_offline: true
          )
      end

      if @session
        @sessionConnection = @session.ute_ex_session_connections.create!(device_id: @deviceId, device_model: params["model"], device_type: @deviceType.id, is_active: true, connected_at: params[:sensor_infos][0][:t])
        
        @devicepairconnotp = generateNewDevicePairConnOtp

        while isActiveDevicePairConnOtpAlreadyExist(@devicepairs, @devicepairconnotp) do
          @devicepairconnotp = generateNewDevicePairConnOtp
        end

        dpc = @devicepairs.ute_device_pair_connections.new(
            is_active: true,
            otp: @devicepairconnotp,
            expire_by: Time.now.getutc.to_f + OTP_DEVICE_PAIR_CONN_LIFETIME, 
            ute_ex_session: @session
          )
        dpc.save! 

        @session.ute_device_pair_connection = dpc
        @session.save!

        is_offline_sensor_data_collection = true
      end
    end 

    if isDataSubmissionInvalidForExpAndSession(request, params) 
        respond_to do |format|
          format.html { render text: 'Unauthorized', :status => :unauthorized }
          format.json { 
            render :json => [], :status => :unauthorized 
          }
        end
      return
    end

    begin
      if params.has_key?(:cell_infos) && params[:cell_infos].empty? == false
        UteDataSubmissionService.delay.handlesensorcells(@session, @sessionConnection, params)
      end
    rescue => e
      puts(e.message)
      raise 'an error has occured'
      #puts(e.backtrace.join("\n"))
    end

    if @devicepairconnection != nil && is_offline_sensor_data_collection 
      #otp needs to be renewed
      @devicepairconnection.update_attributes(
        expire_by: Time.now.getutc.to_f + OTP_DEVICE_PAIR_CONN_LIFETIME
      )
    end    
    
    if is_offline_sensor_data_collection
      render json: { 'status' => 'OK', 'otp' => @devicepairconnotp, 'session_id' => @session.session_code }.to_json
    else
      render json: { 'status' => 'OK' }.to_json
    end
  end

  # POST - submit data for session sensor labels
  def submitSessionLabels
    # check if data submission is offline
    is_offline_sensor_data_collection = false

    # not having valid device id or device type. 
    if (
        params.has_key?(:uid) && (params[:uid].empty? == false)
      )
      @deviceType = nil
      if (
          params.has_key?(:did) == false || params[:did].empty? || 
          params.has_key?(:dtype) == false || params[:dtype].empty? ||
          (@deviceType = DeviceType.where(name: params[:dtype]).first) == nil || 
          params.has_key?(:experiment_id) == false || params[:experiment_id].empty? ||
          (@experiment = UteExperiment.where(:experiment_code => params[:experiment_id], :is_active => true).first) == nil
        ) 
        respond_to do |format|
          format.html { render text: 'Unauthorized', :status => :unauthorized }
          format.json { 
            render :json => [], :status => :unauthorized 
          }
        end
        return
      end

      if (
        params.has_key?(:label_info) == false  || params[:label_info].empty? || 
          params[:label_info][:data].kind_of?(Array) == false || params[:label_info][:data].count == 0
      )
        render json: { 'status' => 'OK' }.to_json
      end

      # check device pairing. 
      @deviceId = params[:did]
      if isPairedDeviceValid(@deviceId, params[:uid]) == false
        respond_to do |format|
          format.html { render text: 'Unauthorized', :status => :unauthorized }
          format.json { 
            render :json => [], :status => :unauthorized 
          }
        end
        return
      end

      # check if devicepairconnotp is not expired yet
      @devicepairconnections = @devicepairs.ute_device_pair_connections.where(
                                                                              :expire_by.gte => Time.now.getutc.to_f, 
                                                                              :is_active => true
                                                                            )
      firststartdate = params[:label_info][:data][0][:t_start]
      @devicepairconnections.each do |devicepairconnection|
        si = devicepairconnection.ute_ex_session
        if si != nil
          if firststartdate > si.range_start_at && firststartdate < si.range_end_at 
            #found the paired connection
            @devicepairconnection = devicepairconnection
            break
          end
        end

        if @devicepairconnection == nil || @devicepairconnection.ute_ex_session == nil 
          #session to pair is not found
          render json: { 'status' => 'FAILED', 'code' => 404 }.to_json
          return
        end
      end

      if @devicepairconnection == nil
        respond_to do |format|
          format.html { render text: 'Unauthorized', :status => :unauthorized }
          format.json { 
            render :json => [], :status => :unauthorized 
          }
        end
        return
      end

      @session = @devicepairconnection.ute_ex_session
      @sessionId = @session.session_code

      if @session
        @sessionConnection = @session.ute_ex_session_connections.create!(device_id: @deviceId, device_model: params["model"], device_type: @deviceType.id, is_active: true, connected_at: params[:label_info][:data][0][:t_start])

        is_offline_sensor_data_collection = true
      end
    end 

    if isDataSubmissionInvalidForExpAndSession(request, params) 
        respond_to do |format|
          format.html { render text: 'Unauthorized', :status => :unauthorized }
          format.json { 
            render :json => [], :status => :unauthorized 
          }
        end
      return
    end

    UteDataSubmissionService.delay.handleintervallabels(@session, @sessionConnection, params)

    if is_offline_sensor_data_collection
      render json: { 'status' => 'OK', 'session_id' => @session.session_code }.to_json
    else
      render json: { 'status' => 'OK' }.to_json
    end
  end

  def closeSessionConnection
    if isDataSubmissionInvalidForExpAndSession(request, params)
        render json: { 'status' => 'OK' }.to_json
      return
    end

    # check if device id is initiator of this session
    # close session when requester is same as initator, set is_active to false to sessions and session_connections tables
    if @sessionConnection.is_active
      @sessionConnection.is_active = false
      @sessionConnection.save
    end
    
    @isInitiator = @session.initiated_by_device_id == @sessionConnection.device_id
    if(@isInitiator)
      @session.is_active = false
      @session.finished_at = Time.now.getutc.to_f
      @session.save
    end

    render json: { 'status' => 'OK' }.to_json
  end

  # PRIVATE class methods 
  private

  def isSessionIdAlreadyExist(experiment_code, sessionId)
    if(sessionId == nil)
      return false
    end

    # check if session ID already exist in DB. 
    return UteExSession.where(:'ute_experiment.experiment_code' => experiment_code, :session_code => sessionId).exists?
  end

  def generateNewSessionId
      return 'S' + (1 + Random.rand(1000000000)).to_s
  end

  def isDataSubmissionInvalidForExpAndSession(request, params)
    invalid = true

    unless @experiment.nil? || @session.nil? || @sessionConnection.nil?
      invalid = false
      return invalid
    end

    invalid = request.format != 'application/json' ||
              request.content_type != 'application/json' ||
              params.has_key?(:experiment_id) == false || params[:experiment_id].empty? ||
              (@experiment = UteExperiment.where(:experiment_code => params[:experiment_id], :is_active => true).first) == nil
              params.has_key?(:session_id) == false || params[:session_id].empty? ||
              (@session = @experiment.ute_ex_sessions.where(session_code: params[:session_id]).first) == nil ||
              params.has_key?(:did) == false || params[:did].empty? || 
              (@sessionConnection = @session.ute_ex_session_connections.where(device_id: params[:did]).first) == nil 
    return invalid
  end

  def isPairedDeviceValid(deviceId, uid)
    @devicepairs = @experiment.ute_device_pairs.where(
                                                    :uuid => uid
                                                  ).first

    if @devicepairs.nil?
      return false
    end

    return @devicepairs.ute_device_pair_requesters.where(:device_id => deviceId, :is_active => true).exists?
  end

  def isActiveDevicePairConnOtpAlreadyExist(otpdevicepair, devicepairconnotp)
    if(otpdevicepair == nil)
      return true
    end

    # check if session ID already exist in DB. 
    return otpdevicepair.ute_device_pair_connections.where(
        :is_active => true, 
        :otp => devicepairconnotp, 
        :expire_by.gte => Time.now.getutc.to_f
    ).exists?
  end

  def generateNewDevicePairConnOtp
    # hardcoded OTP settings 
    otp_length = 10

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