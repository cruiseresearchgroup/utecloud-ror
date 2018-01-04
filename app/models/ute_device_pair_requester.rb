class UteDevicePairRequester
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :ute_device_pair, :inverse_of => :ute_device_pair_requesters
  field :device_id, type: String
  field :device_model, type: String
  field :device_type, type: Integer
  field :is_active, type: Mongoid::Boolean
end
