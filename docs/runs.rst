
.. _runs:

Rerunning
*********

This section first explains how the `MITgcm` can be used to re-run the `ECCO v4 r2` solution over the 1992–2011 period (:numref:`eccov4-baseline`). Other state estimate solutions (:numref:`eccov4-other`), short regression tests (:numref:`testreport`), and optimization tests (:numref:`optim`) are discussed afterwards. 

.. _computers:

.. rubric:: Required Computational Environment

Running the model on a linux cluster requires `gcc` and `gfortran` (or alternative compilers), `mpi` libraries (for parallel computation), and `netcdf` libraries (e.g., for the `profiles` package) as explained in the `MITgcm documentations <http://mitgcm.org/public/docs.html>`__. In `ECCO v4 r2`, the 20-year model run typically takes between 6 to 12 hours when using 96 cores and modern on-premise clusters.

Users who may lack on-premise computational resources or IT support can use `the included cloud computing recipe <https://github.com/gaelforget/ECCOv4/tree/master/docs/example_scripts/>`__ to leverage `Amazon Web Services`'s ``cfncluster`` technology. This recipe sets up a complete computational environment in the `AWS` cloud (hardware, software, model, and inputs). When this recipe was tested in January 2017, the 20-year `ECCO v4 r2` model run took under 36h using 96 vCPUs and `AWS spot instances` for a cost of about 40$. 

.. _eccov4-baseline:

The Release 2 Solution
----------------------

This section assumes that `MITgcm`, the `ECCO v4` setup, and model inputs have been installed according to the :ref:`mitgcmdirs` (see :numref:`download-setup`). Users can then :ref:`baseline` the model to reproduce `ECCO v4 r2`, and :ref:`testreportecco` once the model run has completed.

.. _baseline:

.. rubric:: Compile, Link, And Run

::

    #1) compile model
    cd MITgcm/mysetups/ECCOv4/build
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
    ln -s ../inputs_baseline2/* .
    ln -s ../forcing_baseline2 .

    #3) run model
    mpiexec -np 96 ./mitgcmuv

.. note::

   On most clusters, users would call ``mpiexec`` (or ``mpirun``) via a queuing system rather than directly from the command line. `The cloud computing recipe <https://github.com/gaelforget/ECCOv4/tree/master/docs/example_scripts/>`__ provides an example.

Other compiler options, besides ``linux_amd64_gfortran``, are provided by the `MITgcm` development team in ``MITgcm/tools/build_options/`` for cases when `gfortran` is not available. The number of cores is 96 by default as seen in :ref:`baseline`. It can be reduced to, e.g., 24 simply by copying ``code/SIZE.h_24cores`` over ``code/SIZE.h`` before compiling the model and then running `MITgcm` with ``-np 24`` rather than ``-np 96`` in :ref:`baseline`. It can alternatively be increased to, e.g., 192 cores to speed up the model run or reduce memory requirements. In this case one needs to use ``code/SIZE.h_192cores`` at compile-time and ``input/data.exch2_192cores`` at run-time.

.. _testreportecco:

.. rubric:: Verify Results Accuracy

In Julia, ``testreport_ecco.jl`` provides means to evaluate the accuracy of solution re-runs :cite:`for-eta:15`. To use it, open julia and proceed as follows:

::

    @everywhere begin
     include("test/testreport_ecco.jl")
     using SharedArrays
    end

    report=eccotest.compute("run")

In Matlab, ``testreport_ecco.m`` provides means to evaluate the accuracy of solution re-runs :cite:`for-eta:15`. To use it, open Matlab or Octave and proceed as follows:

::

    cd MITgcm/mysetups/ECCOv4;
    p = genpath('gcmfaces/'); addpath(p); %this can be commented out if needed
    addpath test; %This adds necessary .m and .mat files to path
    mytest=testreport_ecco('run/'); %This compute tests and display results

When using an up-to-date copy of `MITgcm` and a standard computational environment, the expected level of accuracy is reached when all reported values are below -3 :cite:`for-eta:15`. For example:

::

    --------------------------------------------------------------
           &   jT &   jS &      ... &  (reference is)
    run/   & (-3) & (-3) &      ...  &  baseline2      
    --------------------------------------------------------------

Accuracy tests can be carried out for, e.g., meridional transports using the `gcmfaces` toolbox (see :numref:`download-analysis`), but the most basic ones simply rely on the `MITgcm` standard output file (``STDOUT.0000``).

.. _eccov4-other:

Other Known Solutions
---------------------

`ECCO version 4 release 3`: extended solution that covers 1992 to 2015 and was produced by `O. Wang` at JPL; to reproduce this solution follow `O. Wang's directions <ftp://ecco.jpl.nasa.gov/Version4/Release3/doc/ECCOv4r3_reproduction.pdf>`__ or those provided in `ECCOv4r3_mods.md <https://github.com/gaelforget/ECCOv4/blob/master/docs/ECCOv4r3_mods.md>`__. 

`ECCO version 4 baseline 1`: older solution that most closely matches the original, `ECCO version 4 release 1`, solution of :cite:`for-eta:15`; to reproduce this solution follow directions provided in `ECCOv4r1_mods.md <https://github.com/gaelforget/ECCOv4/blob/master/docs/ECCOv4r1_mods.md>`__.

Users who may hold a `TAF <http://www.fastopt.de/>`__ license can also: 

1. compile the adjoint by replacing ``make -j 4`` with ``make adall -j 4`` in :ref:`baseline`

2. activate the adjoint by setting ``useAUTODIFF=.TRUE.,`` in ``input/data.pkg`` 

3. run the adjoint by replacing ``mitgcmuv`` with ``mitgcmuv_ad`` in :ref:`baseline`.

.. _testreport:

Short Forward Tests
-------------------

To ensure continued compatibility with the up to date `MITgcm`, the `ECCO v4` model setup is tested on a daily basis using the ``MITgcm/verification/testreport`` command line utility that compares re-runs with reference results over a few time steps (see below and `the MITgcm howto <http://mitgcm.org/public/docs.html>`__ for additional explanations). These tests use dedicated versions of the `ECCO v4` model setup which are available under `MITgcm_contrib/verification_other/ <https://github.com/MITgcm/verification_other/>`__.

`global_oce_llc90/ <https://github.com/MITgcm/verification_other/tree/master/global_oce_llc90#readme>`__ (595M) uses the same LLC90 grid as the production `ECCO v4` setup does. Users are advised against running even forward LLC90 tests with fewer than 12 cores (96 for adjoint tests) to avoid potential memory overloads. `global_oce_cs32/ <https://github.com/MITgcm/verification_other/tree/master/global_oce_cs32#readme>`__ (614M) uses the much coarser resolution CS32 grid and can thus be used on any modern laptop. Instructions for their installation are provided in `this README <http://mitgcm.org/viewvc/*checkout*/MITgcm/MITgcm_contrib/verification_other/global_oce_llc90/README>`__ and `that README <http://mitgcm.org/viewvc/*checkout*/MITgcm/MITgcm_contrib/verification_other/global_oce_cs32/README>`__, respectively. Once installed, the smaller setup can be executed on one core, for instance, by typing:

::

    cd MITgcm/verification/
    ./testreport -t global_oce_cs32

The test outcome will be reported to screen as shown in :ref:`report`. Daily results of these tests, which currently run on the `glacier` cluster, are reported `on this site <http://mitgcm.org/public/testing.html>`__. To test `global_oce_llc90/ <https://github.com/MITgcm/verification_other/tree/master/global_oce_llc90#readme>`__ using 24 processors and `gfortran` the corresponding command typically is:

::

    cd MITgcm/verification/
    ./testreport -of ../tools/build_options/linux_amd64_gfortran \
    -j 4 -MPI 24 -command 'mpiexec -np TR_NPROC ./mitgcmuv' \
    -t global_oce_llc90

.. _report:

.. rubric:: Sample Test Output

Below is an abbreviated example of testreport output to screen.

::

    default 10  ----T-----  ----S-----  
    G D M    c        m  s        m  s  
    e p a R  g  m  m  e  .  m  m  e  . 
    n n k u  2  i  a  a  d  i  a  a  d  
    2 d e n  d  n  x  n  .  n  x  n  . 

    Y Y Y Y>14<16 16 16 16 16 16 16 16  pass  global_oce_cs32

.. note::

   The degree of agreement (16 digits in :ref:`report`) may vary from computer to computer, and ``testreport`` may even indicate `FAIL`, but this does not mean that users won't be able to reproduce 20-year solutions with acceptable accuracy in :numref:`eccov4-baseline`.

.. _optim:

Other Short Tests
-----------------

Running the adjoint tests associated with :numref:`testreport` requires: (1) holding a `TAF <http://www.fastopt.de/>`__ license; (2) soft linking ``code/`` to ``code_ad/`` in `global_oce_cs32/ <https://github.com/MITgcm/verification_other/tree/master/global_oce_cs32#readme>`__ and `global_oce_llc90/ <https://github.com/MITgcm/verification_other/tree/master/global_oce_llc90#readme>`__. Users that hold a TAF license can then further proceed with the iterative optimization test case in `global_oce_cs32/input_OI/ <https://github.com/MITgcm/verification_other/tree/master/global_oce_cs32/input_OI>`__. For this demo, the ocean model is replaced with a simple diffusion equation.

The pre-requisites are:

#. run the adjoint benchmark in `global_oce_cs32/ <https://github.com/MITgcm/verification_other/tree/master/global_oce_cs32#readme>`__ via testreport (see section `2.3 <#testreport>`__).

#. Go to ``MITgcm/lsopt/`` and compile (see `MITgcm manual <https://mitgcm.readthedocs.io/en/latest/?badge=latest>`__).

#. Go to ``MITgcm/optim/``, replace `natl_box_adjoint` with `global_oce_cs32` in the Makefile, and compile as explained in `MITgcm manual <https://mitgcm.readthedocs.io/en/latest/?badge=latest>`__ to generate the ``optim.x`` executable. If this process failed, please contact mitgcm-support@mit.edu

#. go to ``global_oce_cs32/input_OI/`` and type ``source ./prepare_run``

To match the reference results from ``input_OI/README``, users should proceed as follows

#. ``./mitgcmuv_ad > output.txt``

#. ``./optim.x > op.txt``

#. increment `optimcycle` by 1 in ``data.optim``

#. go back to step #1 to run the next iteration

#. type ``grep fc costfunction00*`` to display results


