# MCL Scarcity Experiment

(forked from [this repo](https://github.com/RationalityEnhancementGroup/mouselab-mdp-example/tree/jsPsych-v7.2.1) for the purposes of defining a single experiment)

This experiment uses the Mouselab-MDP paradigm (see link above) to investigate a hindering factor of meta-cognitive learning, namely scarcity. 

Meta-Cognitive Learning is described as the process by which humans learn how to improve their cognitive strategies. This repository contains code for the implementation of an experiment testing participants on the same planning strategy. On several of the trials, the participants do not receive explicit feedback about the outcome of their plan, i.e., feedback from the environment is scarce. It is investigated whether this effect prevents participants from learning adaptive strategies appropriately, and if so, to which extent.

The experiment was implemented using `jsPsych` and `psiturk`, and was hosted on Heroku.

This repository also contains Jupyter notebooks for preprocessing and analysis of the data collected from the experiment in directory `analysis`

Directories:

* `static`
  * Contains files for the jsPsych implementation of the experiment
  * `json`
    * Contains information about the environments presented to the participants during the experiment
    * `rewards/312_2_4_24.json` is the only file used for this experiment
  * `js`
    * Static JavaScript files important for the functioning of the experiment
* `src`
  * Main experiment files
  * `experiment.coffee` contains the CoffeeScript of the entire experiment implemented using jsPsych
  * `jspsych-mouselab-mdp.coffee` contains CoffeeScript implementation of the Mouselab MDP environment
  * These files compile to the JavaScript files present in `static/js`
* `templates`
  * Contains the default templates for running the psiturk experiment

How to run:

* install python virtual environment and launch
  * `python3 -m venv env & source env/bin/activate`
* install psiturk
  * `pip install psiturk`
* Compile the experiment files
  * `make`
* Run the experiment locally
  * `psiturk server on`
* The experiment can be opened in a web browser at address `https://localhost:22362`

TODO: Add link to paper

Code versions:

* mcl-misaligned-full-r-[1-5].0 - batches of collection of full data for replication study
* mcl-misaligned-test - hosting a test version of the experiment for feedback from others
* mcl-misaligned-full-[2-5].0 - first batch of full experiment data
* mcl-misaligned-full-1.0 - pilot of the updated exclusion criteria 
* mcl-misaligned-full-0.0 - test hosting of full experiment
* mcl-misaligned-pilot-1.5 - pilot to see whether parts clicked on nodes just
* mcl-misaligned-pilot-1.0 - collecting data for first pilot of the misalignment experiment
* mcl-misaligned-0.0 - testing first pilot of the misalignment experiment 
* `mcl-planning-2.0` - second official hosting of planning task pilots (prolific)
* `mcl-planning-1.0` - first official hosting of planning task pilots (prolific)
* `mcl-planning-0.0` - first inofficial hosting of planning task pilots 