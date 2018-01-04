class UteExSessionBluetoothinfo
  include Mongoid::Document
  include Mongoid::Timestamps
  field :uuid, type: String #uuid
  field :name, type: String #name 
  field :rssi, type: BigDecimal #accelerometer_acceleration_z 
  field :t, type: BigDecimal #timestamp
  belongs_to :ute_ex_session_connection, :inverse_of => :ute_ex_session_bluetoothinfos, :index => true

  index({ ute_ex_session_connection: 1, t: 1 })
end