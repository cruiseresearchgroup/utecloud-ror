class UteExSessionConnection
  include Mongoid::Document
  include Mongoid::Timestamps
  field :device_id, type: String
  field :device_model, type: String
  field :device_type, type: Integer
  field :initiated_by_device_id, type: String
  field :connected_at, type: BigDecimal
  field :is_active, type: Mongoid::Boolean
  belongs_to :ute_ex_session, :inverse_of => :ute_ex_session_connections, :index => true
  has_many :ute_ex_session_sensorinfos, class_name: "UteExSessionSensorinfo", dependent: :delete#, store_as: 'sessioninfos'
  has_many :ute_ex_session_bluetoothinfos, class_name: "UteExSessionBluetoothinfo", dependent: :delete
  has_many :ute_ex_session_wifiinfos, class_name: "UteExSessionWifiinfo", dependent: :delete
  has_many :ute_ex_session_cellinfos, class_name: "UteExSessionCellinfo", dependent: :delete
  has_many :ute_ex_session_intervallabels, class_name: "UteExSessionIntervallabel", dependent: :delete#, store_as: 'intervallabels'
  #embeds_many :ute_ex_session_sensorinfos, class_name: "UteExSessionSensorinfo", store_as: 'sessioninfos'
  #embeds_many :ute_ex_session_intervallabels, class_name: "UteExSessionIntervallabel", store_as: 'intervallabels'

  index({ device_type: 1, device_id: 1 })
end