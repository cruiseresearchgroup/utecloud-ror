class UteExSessionIntervallabel
  include Mongoid::Document
  include Mongoid::Timestamps
  field :t_start, type: BigDecimal 
  field :t_end, type: BigDecimal 
  field :labels, type: Array
  belongs_to :ute_ex_session_connection, :inverse_of => :ute_ex_session_intervallabels, :index => true
  #embedded_in :ute_ex_session_connection, :inverse_of => :ute_ex_session_intervallabels

  index({ ute_ex_session_connection: 1, t_start: 1 })
end