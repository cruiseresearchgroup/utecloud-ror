class UteExperimentsController < ApplicationController
  before_action :set_ute_experiment, only: [:show, :edit, :update, :destroy]

  # GET /ute_experiments
  # GET /ute_experiments.json
  def index
    @ute_experiments = UteExperiment.all
  end

  # GET /ute_experiments/1
  # GET /ute_experiments/1.json
  def show
  end

  # GET /ute_experiments/new
  def new
    @ute_experiment = UteExperiment.new
  end

  # GET /ute_experiments/1/edit
  def edit
  end

  # POST /ute_experiments
  # POST /ute_experiments.json
  def create
    @ute_experiment = UteExperiment.new(ute_experiment_params)

    respond_to do |format|
      if @ute_experiment.save
        format.html { redirect_to @ute_experiment, notice: 'Ute experiment was successfully created.' }
        format.json { render :show, status: :created, location: @ute_experiment }
      else
        format.html { render :new }
        format.json { render json: @ute_experiment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ute_experiments/1
  # PATCH/PUT /ute_experiments/1.json
  def update
    respond_to do |format|
      if @ute_experiment.update(ute_experiment_params)
        format.html { redirect_to @ute_experiment, notice: 'Ute experiment was successfully updated.' }
        format.json { render :show, status: :ok, location: @ute_experiment }
      else
        format.html { render :edit }
        format.json { render json: @ute_experiment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ute_experiments/1
  # DELETE /ute_experiments/1.json
  def destroy
    @ute_experiment.destroy
    respond_to do |format|
      format.html { redirect_to ute_experiments_url, notice: 'Ute experiment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ute_experiment
      @ute_experiment = UteExperiment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ute_experiment_params
      params.require(:ute_experiment).permit(:experiment_code, :title, :text, :is_private, :is_active)
    end
end
