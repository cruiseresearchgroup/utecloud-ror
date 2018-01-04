class UteExSessionWifiinfo
  include Mongoid::Document
  include Mongoid::Timestamps
  field :ssid, type: String #ssid
  field :bssid, type: String #bssid 
  field :cap, type: String #capabilities 
  field :bw, type: Integer #channel width 
  field :i_d, type: Mongoid::Boolean #is dual channel
  field :f20, type: Integer #frequency (20mhz)
  field :fc, type: Integer #frequency center 1
  field :fc2, type: Integer #frequency center 2
  field :vn, type: String #venue name
  field :rssi, type: BigDecimal #accelerometer_acceleration_z 
  field :t, type: BigDecimal #timestamp
  belongs_to :ute_ex_session_connection, :inverse_of => :ute_ex_session_wifiinfos, :index => true

  index({ ute_ex_session_connection: 1, t: 1 })
end