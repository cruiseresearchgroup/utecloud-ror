class UteExSession
  include Mongoid::Document
  include Mongoid::Timestamps
  field :session_code, type: String
  field :is_active, type: Mongoid::Boolean
  field :is_created_offline, type: Mongoid::Boolean
  field :initiated_by_device_id, type: String
  field :finished_at, type: BigDecimal
  field :range_start_at, type: BigDecimal
  field :range_end_at, type: BigDecimal
  belongs_to :ute_experiment, :inverse_of => :ute_ex_sessions, :index => true
  has_many :ute_ex_session_connections, dependent: :delete
  belongs_to :ute_device_pair_connection, dependent: :delete
  index({ session_code: 1 })
end