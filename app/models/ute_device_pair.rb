class UteDevicePair
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :ute_experiment, :inverse_of => :ute_device_pairs, :index => true
  field :otp, type: String
  field :uuid, type: String
  field :expire_by, type: BigDecimal
  has_many :ute_device_pair_requesters, dependent: :delete
  has_many :ute_device_pair_connections, dependent: :delete
  field :is_active, type: Mongoid::Boolean

  index({ device_id1: 1 }, { sparse: true })
  index({ device_id2: 1 }, { sparse: true })
  
end