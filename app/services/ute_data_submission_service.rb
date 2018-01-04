class UteDataSubmissionService
  def self.handlesensorinfos(session, sessionConnection, params)
    params[:sensor_infos].each do |item|
      #@sessionConnection.ute_ex_session_sensorinfos.create!(item)
      sessionConnection.ute_ex_session_sensorinfos.create!(
      :aa_x => item[:aa_x],   #accelerometer_acceleration_x 
      :aa_y => item[:aa_y],   #accelerometer_acceleration_y 
      :aa_z => item[:aa_z],   #accelerometer_acceleration_z 
      :mg_x => item[:mg_x],   #motion_gravity_x
      :mg_y => item[:mg_y],   #motion_gravity_y
      :mg_z => item[:mg_z],   #motion_gravity_z
      :mua_x => item[:mua_x], #motion_user_acceleration_x
      :mua_y => item[:mua_y], #motion_user_acceleration_y
      :mua_z => item[:mua_z], #motion_user_acceleration_z
      :ma_y => item[:ma_y],   #motion_attitude_yaw
      :ma_p => item[:ma_p],   #motion_attitude_pitch
      :ma_r => item[:ma_r],   #motion_attitude_roll
      :grr_x => item[:grr_x], #gyroscope_rotationrate_x
      :grr_y => item[:grr_y], #gyroscope_rotationrate_y
      :grr_z => item[:grr_z], #gyroscope_rotationrate_z
      :mrr_x => item[:mrr_x], #motion_rotationrate_x
      :mrr_y => item[:mrr_y], #motion_rotationrate_y
      :mrr_z => item[:mrr_z], #motion_rotationrate_z
      :mh_x => item[:mh_x],   #magnetic_heading_x
      :mh_y => item[:mh_y],   #magnetic_heading_y
      :mh_z => item[:mh_z],   # magnetic_heading_z
      :cmf_x => item[:cmf_x], #calibrated_magnetic_field_x
      :cmf_y => item[:cmf_y], #calibrated_magnetic_field_y
      :cmf_z => item[:cmf_z], #calibrated_magnetic_field_z
      :cmf_a => item[:cmf_a], #calibrated_magnetic_field_accuracy
      :mm_x => item[:mm_x],   #magnetometer_x
      :mm_y => item[:mm_y],   #magnetometer_y
      :mm_z => item[:mm_z],   #magnetometer_z
      :lat => item[:lat],     #latitude
      :lon => item[:lon],     #longitude
      :gps_a => item[:gps_a], #gps_accuracy
      :gps_s => item[:gps_s], #gps_speed
      :pres => item[:pres],   #pressure
      :alt => item[:alt],     #altitude
      :n_l => item[:n_l],     #noise_level
      :t => item[:t]          #timestamp
      )

      if session.range_start_at == nil || session.range_start_at > item[:t]
        session.range_start_at = item[:t]
        session.save
      elsif session.range_end_at == nil || session.range_end_at < item[:t]
        session.range_end_at = item[:t]
        session.save
      end
    end
  end

  def self.handlesensorbluetooths(session, sessionConnection, params)
    params[:bluetooth_infos].each do |item|
      #@sessionConnection.ute_ex_session_sensorinfos.create!(item)
      sessionConnection.ute_ex_session_bluetoothinfos.create!(
      :uuid => item[:uuid],   #uuid 
      :name => item[:name],   #name 
      :rssi => item[:rssi],   #rssi 
      :t => item[:t]          #timestamp
      )

      if session.range_start_at == nil || session.range_start_at > item[:t]
        session.range_start_at = item[:t]
        session.save
      elsif session.range_end_at == nil || session.range_end_at < item[:t]
        session.range_end_at = item[:t]
        session.save
      end
    end
  end

  def self.handlesensorwifis(session, sessionConnection, params)
    params[:wifi_infos].each do |item|
      #@sessionConnection.ute_ex_session_sensorinfos.create!(item)
      sessionConnection.ute_ex_session_wifiinfos.create!(
      :ssid => item[:ssid],     #ssid 
      :bssid => item[:bssid],   #bssid 
      :cap => item[:cap],       #capabilities 
      :bw => item[:bw],         #channel width
      :i_d => item[:i_d],       #is dual channel
      :f20 => item[:f20],       #frequency 20mhz
      :fc => item[:fc],         #frequency center
      :fc2 => item[:fc2],       #frequency center 2, used for dual band
      :vn => item[:vn],         #venue name
      :rssi => item[:rssi],     #rssi 
      :t => item[:t]            #timestamp
      )

      if session.range_start_at == nil || session.range_start_at > item[:t]
        session.range_start_at = item[:t]
        session.save
      elsif session.range_end_at == nil || session.range_end_at < item[:t]
        session.range_end_at = item[:t]
        session.save
      end
    end
  end

  def self.handlesensorcells(session, sessionConnection, params)
    params[:cell_infos].each do |item|
      #@sessionConnection.ute_ex_session_sensorinfos.create!(item)
      sessionConnection.ute_ex_session_cellinfos.create!(
      :cid => item[:cid],       #cid 
      :lac => item[:lac],       #lac 
      :ss => item[:ss],         #signal strength 
      :t => item[:t]            #timestamp
      )

      if session.range_start_at == nil || session.range_start_at > item[:t]
        session.range_start_at = item[:t]
        session.save
      elsif session.range_end_at == nil || session.range_end_at < item[:t]
        session.range_end_at = item[:t]
        session.save
      end
    end
  end

  def self.handleintervallabels(session, sessionConnection, params) 
    if params[:label_info][:type] == 'interval'
      params[:label_info][:data].each do |item|
        sessionConnection.ute_ex_session_intervallabels.create!(
          :t_start => item[:t_start],
          :t_end => item[:t_end],
          :labels => item[:labels]
        )

        if session.range_start_at == nil || session.range_start_at > item[:t_start]
          session.range_start_at = item[:t_start]
          session.save
        elsif session.range_end_at == nil || session.range_end_at < item[:t_end]
          session.range_end_at = item[:t_end]
          session.save
        end
      end
    end
  end
end