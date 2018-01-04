class UteExSetting
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  belongs_to :ute_experiment
end