class UteDevicePairConnection
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :ute_device_pair, :inverse_of => :ute_device_pair_connections
  has_one :ute_ex_session
  field :otp, type: String
  field :expire_by, type: BigDecimal
  field :is_active, type: Mongoid::Boolean
end