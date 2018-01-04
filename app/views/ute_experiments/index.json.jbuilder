json.array!(@ute_experiments) do |ute_experiment|
  json.extract! ute_experiment, :id, :experiment_code, :title, :text, :is_private, :is_active
  json.url ute_experiment_url(ute_experiment, format: :json)
end
