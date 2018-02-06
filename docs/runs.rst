
.. _runs:

Running ECCO Version 4
**********************

This section first explains how the ECCO version 4 setup can be used to re-run the ECCO v4 r2 solution for 1992–2011 (:numref:`eccov4-baseline`). Other state estimate solutions (:numref:`eccov4-other`), short regression tests (:numref:`testreport`), and optimization tests (:numref:`optim`) are discussed afterwards. 

.. _computers:

.. rubric:: Required Computational Environment

Running the model on a linux clusters requires `gcc` and `gfortran` (or alternative compilers), `mpi` libraries (for parallel computation), and `netcdf` libraries (e.g., for the `profiles` package) as explained in the `MITgcm documentations <http://mitgcm.org/public/docs.html>`__. The 20-year ECCO v4 r2 model run typically takes between 6 to 12 hours when using 96 cores and modern on-premise clusters.

Users who may lack on-premise resources or IT support can use `the included cloud computing recipe <https://github.com/gaelforget/ECCO_v4_r2/tree/master/example_scripts/>`__ to leverage `Amazon Web Services`'s ``cfncluster`` technology. This recipe sets up a complete computational environment in the `AWS` cloud (hardware, software, model, and inputs). When this recipe was tested in January 2017, the 20 year ECCO v4 r2 model run completed within 36h using 96 vCPUs and `AWS spot instances` for a cost of about 40$. 

.. _eccov4-baseline:

The Release 2 Solution
----------------------

This section assumes that `MITgcm`, the ECCO v4 setup, and model inputs have been installed according to the :ref:`mitgcmdirs` (see :numref:`download-setup`). Users can then :ref:`baseline` the model to reproduce ECCO v4 r2, and :ref:`testreportecco` once the model run has completed.

.. _baseline:

.. rubric:: Compile, Link, And Run

::

    #1) compile model
    cd MITgcm/mysetups/ECCO_v4_r2/build
    ../../../tools/genmake2 -mods=../code -optfile \
         ../../../tools/build_options/linux_amd64_gfortran -mpi
    make depend
    make -j 4
    cd ..

    #2) link files into run directory
    mkdir run
    cd run
    ln -s ../build/mitgcmuv .
    ln -s ../input/* .
    ln -s ../inputs_baseline2/input*/* .
    ln -s ../forcing_baseline2 .

    #3) run model
    mpiexec -np 96 ./mitgcmuv

Other compiler options, besides ``linux_amd64_gfortran``, are provided by the `MITgcm` development team in ``MITgcm/tools/build_options/`` for cases when `gfortran` is not available. The number of cores is 96 by default as seen in :ref:`baseline`. It can be reduced to 24 simply by copying ``code/SIZE.h_24cores`` over ``code/SIZE.h`` before compiling the model and then running it with ``-np 24`` rather than ``-np 96`` in :ref:`baseline`. It can alternatively be increased to 192 cores to speed up the model run or reduce memory requirements.

.. _testreportecco:

.. rubric:: Verify Results Accuracy

``testreport_ecco.m`` provides a means to evaluate the accuracy of a re-run :cite:`for-eta:15`. To this end, open Matlab or Octave and proceed as follows:

::


    cd MITgcm/mysetups/ECCO_v4_r2
    matlab -nodesktop -nodisplay

    %p = genpath('gcmfaces/'); addpath(p); 

    addpath results_itXX;%add necessary .m and .mat files to path
    mytest=testreport_ecco('run/');%compute tests and display results

When using the up-to-date copy of MITgcm and a standard computing environment, the expected level of accuracy is reached when all reported values are below -3 :cite:`for-eta:15`. For example:

::

    --------------------------------------------------------------
           &   jT &   jS &      ... &  (reference is)
    run/   & (-3) & (-3) &      ...  &  baseline2      
    --------------------------------------------------------------

Additional accuracy tests can be carried out for, e.g., meridional transports using the `gcmfaces` toolbox (see :numref:`download-analysis`) by uncommenting `p = genpath...`` in the above instructions.

.. _eccov4-other:

Re-Run Other Solutions
----------------------

It is here assumed that `MITgcm` and ECCO v4 directories have been downloaded and organized as shown in :ref:`mitgcmdirs`. 

Users can then re-run the `baseline 1` solution that more closely matches the original, `release 1`, solution of :cite:`for-eta:15`. However, to re-run `baseline 1` instead of `release 2`, a few modifications to the setup are needed: (a) download the corresponding forcing fields as follows:

::

    wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release1/forcing_baseline1/

(b) before compiling the model: define ``ALLOW_KAPGM_CONTROL_OLD`` and
``ALLOW_KAPREDI_CONTROL_OLD`` in ``code/GMREDI_OPTIONS.h``;
define ``ALLOW_AUTODIFF_INIT_OLD`` in
``code/AUTODIFF_OPTIONS.h``; (c) before running the model: copy
``input_itXX/data`` and ``data.exf`` over ``input/data``
and ``data.exf``. 
Users who may want to reproduce `release 1` even more precisely than
`baseline 1` does should contact ecco-support@mit.edu to obtain
additional model inputs.

Users holding a `TAF <http://www.fastopt.de/>`__ license can also: 
(a) compile the adjoint by replacing ``make -j 4`` with ``make adall -j 4``
in :ref:`baseline`; (b) activate the adjoint by setting
``useAUTODIFF=.TRUE.,`` in ``data.pkg``; (c) run the adjoint by replacing
``mitgcmuv`` with ``mitgcmuv_ad`` in :ref:`baseline`.

.. _testreport:

Short Forward Tests
-------------------

To ensure continued compatibility with the up to date `MITgcm`, the ECCO v4 model setup is also tested on a daily basis using the ``MITgcm/verification/testreport`` command line utility that compares re-runs with reference results over a few time steps (see below and `the MITgcm howto <http://mitgcm.org/public/docs.html>`__ for additional explanations). These tests use dedicated versions of the ECCO v4 model setup which are available via the `MITgcm_contrib/verification_other/ <http://mitgcm.org/viewvc/MITgcm/MITgcm_contrib/verification_other/>`__ server.

`global_oce_llc90/ <http://mitgcm.org/viewvc/MITgcm/MITgcm_contrib/verification_other/global_oce_llc90/>`__ (595M) uses the same LLC90 grid as the production ECCO v4 setup does (section `2.1 <#eccov4-baseline>`__). Users are advised against running forward tests using fewer than 12 cores (96 for adjoint tests) to avoid potential memory overloads. `global_oce_cs32/ <http://mitgcm.org/viewvc/MITgcm/MITgcm_contrib/verification_other/global_oce_cs32/>`__ (614M) uses the much coarser resolution CS32 grid and can thus be used on any modern laptop. Instructions for their installation are provided in `this README <http://mitgcm.org/viewvc/*checkout*/MITgcm/MITgcm_contrib/verification_other/global_oce_llc90/README>`__ and `that README <http://mitgcm.org/viewvc/*checkout*/MITgcm/MITgcm_contrib/verification_other/global_oce_cs32/README>`__, respectively. Once installed, the smaller setup for instance can be executed on one core by typing:

::

    cd MITgcm/verification/
    ./testreport -t global_oce_cs32

If everything proceeds as expected then the results are reported to screen as shown in :ref:`report`. The daily results of the regression tests (ran on the `glacier` cluster) are reported `on this site <http://mitgcm.org/public/testing.html>`__. On other machines the degree of agreement (16 digits in :ref:`report`) may vary and testreport may indicate `FAIL`. Note: despite the seemingly dramatic character of this message, users may still be able to reproduce 20-year solutions with acceptable accuracy (:numref:`eccov4-baseline`). To test `global_oce_llc90/ <http://mitgcm.org/viewvc/MITgcm/MITgcm_contrib/verification_other/global_oce_llc90/>`__ using 24 processors and `gfortran` the corresponding command typically is:

::

    cd MITgcm/verification/
    ./testreport -of ../tools/build_options/linux_amd64_gfortran \
    -j 4 -MPI 24 -command 'mpiexec -np TR_NPROC ./mitgcmuv' \
    -t global_oce_llc90

.. _report:

.. rubric:: Verify Short Test

Below is an abbreviated example of testreport output to screen.

::

    default 10  ----T-----  ----S-----  
    G D M    c        m  s        m  s  
    e p a R  g  m  m  e  .  m  m  e  . 
    n n k u  2  i  a  a  d  i  a  a  d  
    2 d e n  d  n  x  n  .  n  x  n  . 

    Y Y Y Y>14<16 16 16 16 16 16 16 16  pass  global_oce_cs32

.. _optim:

Other Short Tests
-----------------

Running the adjoint tests associated with :numref:`testreport` requires: (1) a `TAF <http://www.fastopt.de/>`__ license; (2) to soft link ``code/`` as ``code_ad/`` in `global_oce_cs32/ <http://mitgcm.org/viewvc/MITgcm/MITgcm_contrib/verification_other/global_oce_cs32/>`__ and `global_oce_llc90/ <http://mitgcm.org/viewvc/MITgcm/MITgcm_contrib/verification_other/global_oce_llc90/>`__. Users that hold a TAF license can then further proceed with the iterative optimization test case in `global_oce_cs32/input_OI/ <http://mitgcm.org/viewvc/MITgcm/MITgcm_contrib/verification_other/global_oce_cs32/input_OI>`__. Here the ocean model is replaced with a simple diffusion equation.

The pre-requisites are:

#. run the adjoint benchmark in `global_oce_cs32/ <http://mitgcm.org/viewvc/MITgcm/MITgcm_contrib/verification_other/global_oce_cs32/>`__ via testreport (see section `2.3 <#testreport>`__).

#. Go to ``MITgcm/lsopt/`` and compile (see section 3.18 in `manual <http://mitgcm.org/public/r2_manual/latest/online_documents/manual.pdf>`__).

#. Go to ``MITgcm/optim/``, replace `natl_box_adjoint` with `global_oce_cs32` in `this Makefile <http://mitgcm.org/viewvc/MITgcm/optim/Makefile>`__, and compile as explained in section 3.18 of `manual <http://mitgcm.org/public/r2_manual/latest/online_documents/manual.pdf>`__. An executable named ``optim.x`` should get created in ``MITgcm/optim/``. If otherwise, please contact mitgcm-support@mit.edu

#. go to ``global_oce_cs32/input_OI/`` and type ``source ./prepare_run``

To match the reference results reported in `this file <http://mitgcm.org/viewvc/*checkout*/MITgcm/MITgcm_contrib/verification_other/global_oce_cs32/input_OI/README>`__, users should proceed as follows

#. ``./mitgcmuv_ad > output.txt``

#. ``./optim.x > op.txt``

#. increment `optimcycle` by 1 in ``data.optim``

#. go back to step #1 to run the next iteration

#. type ``grep fc costfunction00*`` to display results


