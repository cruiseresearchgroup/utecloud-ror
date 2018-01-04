module PortalHelper
  SESSION_INFOS_CSV_HEADER = [
        #:datetime,
        #:milliseconds,
        #:timestamp_epoch,
        :timestamp,
        :accelerometer_acceleration_x, 
        :accelerometer_acceleration_y,
        :accelerometer_acceleration_z,
        :motion_gravity_x,
        :motion_gravity_y,
        :motion_gravity_z,
        :motion_user_acceleration_x,
        :motion_user_acceleration_y,
        :motion_user_acceleration_z,
        :motion_attitude_yaw,
        :motion_attitude_pitch,
        :motion_attitude_roll,
        :gyroscope_rotationrate_x,
        :gyroscope_rotationrate_y,
        :gyroscope_rotationrate_z,
        :motion_rotationrate_x,
        :motion_rotationrate_y,
        :motion_rotationrate_z,
        :magnetic_heading_x,
        :magnetic_heading_y,
        :magnetic_heading_z,
        :calibrated_magnetic_field_x,
        :calibrated_magnetic_field_y,
        :calibrated_magnetic_field_z,
        :calibrated_magnetic_field_accuracy,
        :magnetometer_x,
        :magnetometer_y,
        :magnetometer_z,
        :latitude,
        :longitude,
        :gps_accuracy,
        :gps_speed,
        :pressure,
        :altitude,
        :noise_level
      ]

  BLUETOOTH_INFOS_CSV_HEADER = [
    :timestamp,
    :uuid,
    :name,
    :rssi
  ]

  WIFI_INFOS_CSV_HEADER = [
    :timestamp,
    :ssid,
    :bssid,
    :cap,
    :bw,
    :i_d,
    :f20,
    :fc,
    :fc2,
    :vn,
    :rssi
  ]

  CELL_INFOS_CSV_HEADER = [
    :timestamp,
    :cid,
    :lac,
    :ss
  ]

  INTERVAL_LABEL_CSV_HEADER = [
    :timestamp_start,
    :timestamp_end,
    :labels
  ]

  def self.sessioninfo_csv_header
    #Using ruby's built-in CSV::Row class
    #true - means its a header
    CSV::Row.new(SESSION_INFOS_CSV_HEADER,
      [
        #'datetime',
        #'milliseconds',
        #'timestamp_epoch',
        'timestamp',
        'accelerometer_acceleration_x', 
        'accelerometer_acceleration_y',
        'accelerometer_acceleration_z',
        'motion_gravity_x',
        'motion_gravity_y',
        'motion_gravity_z',
        'motion_user_acceleration_x',
        'motion_user_acceleration_y',
        'motion_user_acceleration_z',
        'motion_attitude_yaw',
        'motion_attitude_pitch',
        'motion_attitude_roll',
        'gyroscope_rotationrate_x',
        'gyroscope_rotationrate_y',
        'gyroscope_rotationrate_z',
        'motion_rotationrate_x',
        'motion_rotationrate_y',
        'motion_rotationrate_z',
        'magnetic_heading_x',
        'magnetic_heading_y',
        'magnetic_heading_z',
        'calibrated_magnetic_field_x',
        'calibrated_magnetic_field_y',
        'calibrated_magnetic_field_z',
        'calibrated_magnetic_field_accuracy',
        'magnetometer_x',
        'magnetometer_y',
        'magnetometer_z',
        'latitude',
        'longitude',
        'gps_accuracy',
        'gps_speed',
        'pressure',
        'altitude',
        'noise_level'
      ], true)
  end

  def self.sessioninfo_to_csv_row(row)
    #@wkbHex = RtDriverSessionController.convertToGeometryPoint(row['location_latitude'] || 0, row['location_longitude'] || 0)
    #@timestamp = Time.at(row['t'] == nil ? 0 : row['t'].try(:to_d) || 0)
    #@timestampTime = Time.at(@timestamp)
    CSV::Row.new(SESSION_INFOS_CSV_HEADER,
      [
        row['t'].try(:to_d),
        #@timestampTime,
        #@timestampTime.nsec,
        #@timestamp.to_f,
        row['aa_x'].try(:to_d),     #accelerometer_acceleration_x 
        row['aa_y'].try(:to_d),     #accelerometer_acceleration_y 
        row['aa_z'].try(:to_d),     #accelerometer_acceleration_z 
        row['mg_x'].try(:to_d),     #motion_gravity_x
        row['mg_y'].try(:to_d),     #motion_gravity_y
        row['mg_z'].try(:to_d),     #motion_gravity_z
        row['mua_x'].try(:to_d),    #motion_user_acceleration_x
        row['mua_y'].try(:to_d),    #motion_user_acceleration_y
        row['mua_z'].try(:to_d),    #motion_user_acceleration_z
        row['ma_y'].try(:to_d),     #motion_attitude_yaw
        row['ma_p'].try(:to_d),     #motion_attitude_pitch
        row['ma_r'].try(:to_d),     #motion_attitude_roll
        row['grr_x'].try(:to_d),    #gyroscope_rotationrate_x
        row['grr_y'].try(:to_d),    #gyroscope_rotationrate_y
        row['grr_z'].try(:to_d),    #gyroscope_rotationrate_z
        row['mrr_x'].try(:to_d),    #motion_rotationrate_x
        row['mrr_y'].try(:to_d),    #motion_rotationrate_y
        row['mrr_z'].try(:to_d),    #motion_rotationrate_z
        row['mh_x'].try(:to_d),     #magnetic_heading_x
        row['mh_y'].try(:to_d),     #magnetic_heading_y
        row['mh_z'].try(:to_d),     # magnetic_heading_z
        row['cmf_x'].try(:to_d),    #calibrated_magnetic_field_x
        row['cmf_y'].try(:to_d),    #calibrated_magnetic_field_y
        row['cmf_z'].try(:to_d),    #calibrated_magnetic_field_z
        row['cmf_a'].try(:to_d),    #calibrated_magnetic_field_accura
        row['mm_x'].try(:to_d),     #magnetometer_x
        row['mm_y'].try(:to_d),     #magnetometer_y
        row['mm_z'].try(:to_d),     #magnetometer_z
        row['lat'].try(:to_d),      #latitude
        row['lon'].try(:to_d),      #longitude
        row['gps_a'].try(:to_d),    #gps_accuracy
        row['gps_s'].try(:to_d),    #gps_speed
        row['pres'].try(:to_d),    #gps_speed
        row['alt'].try(:to_d),    #gps_speed
        row['n_l'].try(:to_d)       #noise_level
      ])
  end

  def self.bluetoothinfo_csv_header
    #Using ruby's built-in CSV::Row class
    #true - means its a header
    CSV::Row.new(BLUETOOTH_INFOS_CSV_HEADER,
      [
        'timestamp',
        'uuid', 
        'name',
        'rssi',
      ], true)
  end

  def self.bluetoothinfo_to_csv_row(row)
    CSV::Row.new(BLUETOOTH_INFOS_CSV_HEADER,
      [
        row['t'].try(:to_d),
        row['uuid'],               #uuid 
        row['name'],               #name 
        row['rssi'].try(:to_d)     #rssi 
      ])
  end

  def self.wifiinfo_csv_header
    #Using ruby's built-in CSV::Row class
    #true - means its a header
    CSV::Row.new(WIFI_INFOS_CSV_HEADER,
      [
        'timestamp',
        'ssid', 
        'bssid',
        'capabilities',
        'channel_width',
        'is_dual_channel',
        'frequency',
        'frequency_center_1',
        'frequency_center_2',
        'venue_name',
        'rssi',
      ], true)
  end

  def self.wifiinfo_to_csv_row(row)
    CSV::Row.new(WIFI_INFOS_CSV_HEADER,
      [
        row['t'].try(:to_d),
        row['ssid'],                            #ssid 
        row['bssid'],                           #bssid 
        row['cap'],                           #capabilities 
        row['bw'],                              #channel width 
        if row['i_d'] then 1 else 0 end,        #is dual channel? 
        row['f20'],                             #frequency (20mhz) 
        row['fc'],                              #frequency center 1
        row['fc2'],                             #frequency center 2
        row['vn'],                              #venue name
        row['rssi'].try(:to_d)                  #rssi 
      ])
  end

  def self.cellinfo_csv_header
    #Using ruby's built-in CSV::Row class
    #true - means its a header
    CSV::Row.new(CELL_INFOS_CSV_HEADER,
      [
        'timestamp',
        'cid', 
        'lac',
        'signal_strength'
      ], true)
  end

  def self.cellinfo_to_csv_row(row)
    CSV::Row.new(CELL_INFOS_CSV_HEADER,
      [
        row['t'].try(:to_d),
        row['cid'],                             #cid 
        row['lac'],                             #lac  
        row['ss']                               #signal strength 
      ])
  end

  def self.intervallabel_csv_header
    #Using ruby's built-in CSV::Row class
    #true - means its a header
    CSV::Row.new(INTERVAL_LABEL_CSV_HEADER,
      [
        'timestamp_start',
        'timestamp_end',
        'labels'
      ], true)
  end

  def self.intervallabel_to_csv_row(row)
    if row['labels'].nil?
        return
    end

    CSV::Row.new(INTERVAL_LABEL_CSV_HEADER,
      [
        row['t_start'].try(:to_d),
        row['t_end'].try(:to_d),
        row['labels'].join(':')
      ])
  end

  def self.find_in_batches(filters, batch_size, &block)
    #find_each will batch the results instead of getting all in one go
    where(filters).find_each(batch_size: batch_size) do |transaction|
      yield transaction
    end
  end
end
