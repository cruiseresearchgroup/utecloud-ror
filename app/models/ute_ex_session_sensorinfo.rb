class UteExSessionSensorinfo
  include Mongoid::Document
  include Mongoid::Timestamps
  field :aa_x, type: BigDecimal #accelerometer_acceleration_x 
  field :aa_y, type: BigDecimal #accelerometer_acceleration_y 
  field :aa_z, type: BigDecimal #accelerometer_acceleration_z 
  field :mg_x, type: BigDecimal #motion_gravity_x
  field :mg_y, type: BigDecimal #motion_gravity_y
  field :mg_z, type: BigDecimal #motion_gravity_z
  field :mua_x, type: BigDecimal #motion_user_acceleration_x
  field :mua_y, type: BigDecimal #motion_user_acceleration_y
  field :mua_z, type: BigDecimal #motion_user_acceleration_z
  field :ma_y, type: BigDecimal #motion_attitude_yaw
  field :ma_p, type: BigDecimal #motion_attitude_pitch
  field :ma_r, type: BigDecimal #motion_attitude_roll
  field :grr_x, type: BigDecimal #gyroscope_rotationrate_x
  field :grr_y, type: BigDecimal #gyroscope_rotationrate_y
  field :grr_z, type: BigDecimal #gyroscope_rotationrate_z
  field :mrr_x, type: BigDecimal #motion_rotationrate_x
  field :mrr_y, type: BigDecimal #motion_rotationrate_y
  field :mrr_z, type: BigDecimal #motion_rotationrate_z
  field :mh_x, type: BigDecimal #magnetic_heading_x
  field :mh_y, type: BigDecimal #magnetic_heading_y
  field :mh_z, type: BigDecimal # magnetic_heading_z
  field :cmf_x, type: BigDecimal #calibrated_magnetic_field_x
  field :cmf_y, type: BigDecimal #calibrated_magnetic_field_y
  field :cmf_z, type: BigDecimal #calibrated_magnetic_field_z
  field :cmf_a, type: BigDecimal #calibrated_magnetic_field_accuracy
  field :mm_x, type: BigDecimal #magnetometer_x
  field :mm_y, type: BigDecimal #magnetometer_y
  field :mm_z, type: BigDecimal #magnetometer_z
  field :lat, type: BigDecimal #latitude
  field :lon, type: BigDecimal #longitude
  field :gps_a, type: BigDecimal #gps_accuracy
  field :gps_s, type: BigDecimal #gps_speed
  field :n_l, type: BigDecimal #noise_level
  field :pres, type: BigDecimal #pressure 
  field :alt, type: BigDecimal #altitude
  field :t, type: BigDecimal #timestamp
  belongs_to :ute_ex_session_connection, :inverse_of => :ute_ex_session_sensorinfos, :index => true
  #embedded_in :ute_ex_session_connection, :inverse_of => :ute_ex_session_sensorinfos

  index({ ute_ex_session_connection: 1, t: 1 })
end