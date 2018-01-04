class UteExperiment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  field :experiment_code, type: String
  field :talias, type: String
  field :title, type: String
  field :text, type: String
  field :is_private, type: Mongoid::Boolean
  field :is_cacheable, type: Mongoid::Boolean
  field :is_active, type: Mongoid::Boolean
  field :created_on, type: BigDecimal
  field :created_by, type: Integer
  field :owner, type: Integer
  field :eligible_accessors, type: Array
  field :campaign_end_at, type: BigDecimal
  #field :settings, type: Array
  has_many :ute_ex_sessions, dependent: :delete
  has_many :ute_device_pairs, dependent: :delete
  embeds_one :ute_ex_setting, cascade_callbacks: true

  index({ experiment_code: 1 })

  def getSensorSettingsFreqValue(key)
    if(self[:settings] && self[:settings][:sensors].to_a.any?)
      firstItem = self[:settings][:sensors].select { |i| i[:name] == key }
      if firstItem.to_a.any?
        return firstItem[0][:freq] 
      else 
        return nil
      end
    end
  end

  def getSensorSettingsSecValue(key)
    if(self[:settings] && self[:settings][:sensors].to_a.any?)
      firstItem = self[:settings][:sensors].select { |i| i[:name] == key }
      if firstItem.to_a.any?
        return firstItem[0][:sec] 
      else 
        return nil
      end
    end
  end
end
