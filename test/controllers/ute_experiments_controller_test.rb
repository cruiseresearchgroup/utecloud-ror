require 'test_helper'

class UteExperimentsControllerTest < ActionController::TestCase
  setup do
    @ute_experiment = ute_experiments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ute_experiments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ute_experiment" do
    assert_difference('UteExperiment.count') do
      post :create, ute_experiment: { experiment_code: @ute_experiment.experiment_code, is_active: @ute_experiment.is_active, is_private: @ute_experiment.is_private, text: @ute_experiment.text, title: @ute_experiment.title }
    end

    assert_redirected_to ute_experiment_path(assigns(:ute_experiment))
  end

  test "should show ute_experiment" do
    get :show, id: @ute_experiment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ute_experiment
    assert_response :success
  end

  test "should update ute_experiment" do
    patch :update, id: @ute_experiment, ute_experiment: { experiment_code: @ute_experiment.experiment_code, is_active: @ute_experiment.is_active, is_private: @ute_experiment.is_private, text: @ute_experiment.text, title: @ute_experiment.title }
    assert_redirected_to ute_experiment_path(assigns(:ute_experiment))
  end

  test "should destroy ute_experiment" do
    assert_difference('UteExperiment.count', -1) do
      delete :destroy, id: @ute_experiment
    end

    assert_redirected_to ute_experiments_path
  end
end
