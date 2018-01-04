class UteExSessionCellinfo
  include Mongoid::Document
  include Mongoid::Timestamps
  field :cid, type: Integer #cid
  field :lac, type: Integer #lac 
  field :ss, type: Integer #ss 
  field :t, type: BigDecimal #timestamp
  belongs_to :ute_ex_session_connection, :inverse_of => :ute_ex_session_cellinfos, :index => true

  index({ ute_ex_session_connection: 1, t: 1 })
end