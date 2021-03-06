#!/bin/bash

# modified from https://github.com/trevorstephens/gplearn

# This script is meant to be called by the "install" step defined in
# .travis.yml. See http://docs.travis-ci.com/ for more details.
# The behavior of the script is controlled by environment variabled defined
# in the .travis.yml in the top level folder of the project.


# License: GNU/GPLv3

set -e

# Fix the compilers to workaround avoid having the Python 3.4 build
# lookup for g++44 unexpectedly.
export CC=gcc
export CXX=g++

# Deactivate the travis-provided virtual environment and setup a
# conda-based environment instead
deactivate

# Use the miniconda installer for faster download / install of conda
# itself
wget http://repo.continuum.io/miniconda/Miniconda-3.9.1-Linux-x86_64.sh \
    -O miniconda.sh
chmod +x miniconda.sh && ./miniconda.sh -b
export PATH=/home/travis/miniconda/bin:$PATH
conda update --yes conda

# Configure the conda environment and put it in the path using the
# provided versions
if [[ "$LATEST" == "true" ]]; then
    conda create -n testenv --yes python=$PYTHON_VERSION pip nose \
        numpy scipy cython pandas matplotlib numba ipython seaborn notebook 
else
    # You can specify exact versions of packages here
    conda create -n testenv --yes python=$PYTHON_VERSION pip nose \
        numpy=$NUMPY_VERSION scipy=$SCIPY_VERSION \
	pandas=$PANDAS_VERSION \
	matplotlib \
	numba \
	ipython \
	seaborn \
	notebook \
        cython
fi

source activate testenv

if [[ "$COVERAGE" == "true" ]]; then
    pip install coverage coveralls
fi

# build output in the travis output when it succeeds.
python --version
python -c "import numpy; print('numpy %s' % numpy.__version__)"
python -c "import scipy; print('scipy %s' % scipy.__version__)"
python -c "import pandas; print('pandas %s' % pandas.__version__)"
python -c "import matplotlib; print('matplotlib %s' % matplotlib.__version__)"
python -c "import numba; print('numba %s ' % numba.__version__)"
python -c "import ipython; print('ipython %s ' % ipython.__version__)"
python -c "import seaborn; print('seaborn %s ' % seaborn.__version__)"
python -c "import notebook; print('notebook %s ' % notebook.__version__)"
python setup.py build_ext --inplace
