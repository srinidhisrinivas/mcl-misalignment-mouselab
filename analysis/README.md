This directory contains analysis notebooks for the preprocessing and analysis of participant data.

How to run:
* create python virtual environment
  * `python3 -m venv env`
* Activate virtual environment
  * `source env/bin/activate`
* Install mouselab
  * `pip install -e .`
* Install other necessary packages for notebooks
  * `pip install -r requirements.txt`
* Open jupyter notebook
  * `jupyter notebook`

The experiment data should be present in the `results/anonymized_data` folder of the root directory.

The following notebooks are relevant for processing the above data:
* `Data Analysis.ipynb` - statistical analyses of the data
* `Model Analysis.ipynb`
  * Creating dataframes for model comparison with spm12
  * Analysing the results of model comparison with spm12