
.. role:: math(raw)
   :format: html latex
..

.. role:: raw-latex(raw)
   :format: latex
..

.. raw:: latex

   \maketitle

.. raw:: latex

   \vspace{1cm}

Abstract
********

ECCO v4 r2 (Estimating the Circulation and Climate of the Ocean, version
4, release 2) is a state estimate covering the period from 1992 to 2011
:raw-latex:`\citep{dspace-eccov4r2}`. This minor update of the original
ECCO v4 solution :raw-latex:`\citep{gmd-8-3071-2015}` benefits from a
few additional corrections
:raw-latex:`\citep[listed in][]{dspace-eccov4r2}`, is provided with
additional model-data misfit and model budget output, and is easier to
re-run. Section `1 <#downloads>`__ provides an installation guide and
links to analysis tools [1]_. Section `2 <#runs>`__ provides simple
instructions that allow users to re-run ECCO v4 r2 in order to generate
additional model output or to setup their own model experiments.

.. raw:: latex

   \tableofcontents

.. raw:: latex

   \clearpage

.. raw:: latex

   \newpage

.. raw:: latex

   \linenumbers

.. _downloads:

Downloading ECCO Version 4
**************************

This section provides directions to download the ECCO v4 r2 output (sec.
`1.1 <#download-solution>`__), the underlying model setup (sec.
`1.2 <#download-setup>`__) that can be used to re-run ECCO v4 r2 (sec.
`2.1 <#eccov4-baseline>`__), Matlab tools to analyze ECCO v4 r2 and
other model output (sec. `1.3 <#download-analysis>`__), and a list of
additional resources (sec. `1.4 <#other-resources>`__).

.. _download-solution:

The Release 2 Solution
----------------------

The ECCO v4 r2 state estimate output is permanently archived within the
`Harvard Dataverse <https://dataverse.harvard.edu/dataverse/ECCOv4r2>`__
that provides citable identifiers for the various datasets as reported
in this
`README.pdf <https://dataverse.harvard.edu/api/access/datafile/2863409>`__.
For download purposes, the ECCO v4 r2 output is also made available via
this `ftp
server <ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/>`__ by
the `ECCO Consortium <http://ecco-group.org>`__. The various directory
contents are summarized in this
`README <http://mit.ecco-group.org/opendap/ecco_for_las/version_4/release2/README>`__
and specific details are provided in each subdirectory’s README. Under
Linux or macOS for instance, a simple download method consists in using
‘wget’ at the command line by typing

::

    wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/nctiles_grid
    wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/nctiles_climatology
    wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/nctiles_monthly

and similarly for the other directories. The ‘nctiles\_’ directory
prefix indicates that contents are provided on the native LLC90 grid in
the nctiles format :raw-latex:`\citep{gmd-8-3071-2015}` which can be
read in Matlab using the gcmfaces toolbox (see
section \ `1.3 <#download-analysis>`__). Alternatively users can
download interpolated fields, on a :math:`1/2\times1/2^\circ` grid in
the netcdf format, from the ‘interp\_’ directories. The ‘input\_’
directories contain binary and netcdf input files that can be read by
MITgcm (sections `1.2 <#download-setup>`__ and
`2.1 <#eccov4-baseline>`__). The `profiles
directory <ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/profiles/>`__
contains the MITprof collections of collocated in situ and state
estimate profiles in ‘netcdf’ format
:raw-latex:`\citep{gmd-8-3071-2015}`.

.. _download-setup:

The Release 2 Setup
-------------------

First, install the MITgcm either by downloading a copy from `this
webpage <http://mitgcm.org/download/other_checkpoints/>`__
(MITgcm_c66e.tar.gz is the latest release at present time) or by using
the `MITgcm cvs server <http://mitgcm.org/public/using_cvs.html>`__ as
explained in `that webpage <http://mitgcm.org/public/using_cvs.html>`__.
Second, create a subdirectory called ‘MITgcm/mysetups/’ and install the
ECCO v4 r2 model setup in this directory either from `this github
repository <https://github.com/gaelforget/ECCO_v4_r2/>`__ by typing:

::

    mkdir MITgcm/mysetups
    cd MITgcm/mysetups
    git clone https://github.com/gaelforget/ECCO_v4_r2

or from the `MITgcm cvs
server <http://mitgcm.org/public/using_cvs.html>`__ by typing:

::

    mkdir MITgcm/mysetups
    cd MITgcm/mysetups
    cvs co -P -d ECCO_v4_r2 MITgcm_contrib/gael/verification/ECCO_v4_r2

or by downloading a copy via `this
webpage <http://mit.ecco-group.org/opendap/ecco_for_las/version_4/checkpoints/>`__
(c66e_eccov4r2.tar at present time). Third, download the three-hourly
forcing fields (96G; to re-run ECCO v4 r2 in
section \ `2.1 <#eccov4-baseline>`__) and observational data (25G; to
verify ECCO v4 r2 re-runs in section \ `2.1 <#eccov4-baseline>`__) model
inputs either from the `Harvard
Dataverse <https://dataverse.harvard.edu/dataverse/ECCOv4r2inputs>`__
permanent archive or from the `ECCO ftp
server <ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/>`__ as
follows:

::

    cd MITgcm/mysetups/ECCO_v4_r2
    wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/input_forcing/
    wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/input_ecco/
    wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/input_init/
    mv mit.ecco-group.org/ecco_for_las/version_4/release2/input_forcing forcing_baseline2
    mv mit.ecco-group.org/ecco_for_las/version_4/release2/input_ecco inputs_baseline2
    mv mit.ecco-group.org/ecco_for_las/version_4/release2/input_init inputs_baseline2/.

Fig. \ `[mitgcmdirs] <#mitgcmdirs>`__ provides a graphical depiction of
the downloaded directories organized as is expected in
section \ `2.1 <#eccov4-baseline>`__. Experienced users should feel free
to re-organize directories assuming that they are comfortable with
modifying the section \ `2.1 <#eccov4-baseline>`__ and
Fig. \ `[baseline] <#baseline>`__ instructions accordingly.

.. _download-analysis:

Matlab Analysis Tools
---------------------

Matlab tools are provided to analyze model output from section
`1.1 <#download-solution>`__ or section `2.1 <#eccov4-baseline>`__
include:

-  | The gcmfaces Matlab toolbox :raw-latex:`\citep{gmd-8-3071-2015}`
     gets installed as explained in the
   | `gcmfaces.pdf <http://mitgcm.org/viewvc/*checkout*/MITgcm/MITgcm_contrib/gael/matlab_class/gcmfaces.pdf>`__
     documentation. It can be used, for example, to re-generate the
     ‘standard analysis’ for ECCO v4 r2 (i.e., the plots included in
     :raw-latex:`\cite{dspace-eccov4r2}`) from the released model output
     (sec. `1.1 <#download-solution>`__) or from the plain, binary,
     model output (sec. `2.1 <#eccov4-baseline>`__).

-  The stand-alone
   `eccov4_lonlat.m <http://mit.ecco-group.org/opendap/ecco_for_las/version_4/release2/doc/eccov4_lonlat.m>`__
   Matlab script can be used to extract the lat-lon sector (i.e., array)
   of the gridded output that spans the :math:`69^\circ`\ S to
   :math:`56^\circ`\ N latitude range.

Other Resources
---------------

-  Any netcdf enabled software (e.g.,
   `Panoply <http://www.giss.nasa.gov/tools/panoply/>`__ in MS-Windows,
   Linux, or macOS) should be able to read the interpolated output for
   `the monthly
   climatology <ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/interp_climatology/>`__
   or `the monthly time
   series <ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/interp_monthly/>`__.

-  The ECCO v4 r2 state estimate can also be downloaded and analyzed via
   the NASA Sea Level Change Portal tools (https://sealevel.nasa.gov;
   interpolated fields only) and the Harvard Dataverse APIs
   (https://dataverse.harvard.edu; all inputs and outputs).

-  xmitgcm provides a python alternative
   (https://github.com/xgcm/xmitgcm) to using Matlab and gcmfaces
   (https://github.com/gaelforget/gcmfaces)

-  The `MITgcm/utils/ <http://mitgcm.org/viewvc/MITgcm/MITgcm/utils/>`__
   directory which can be downloaded via the MITgcm `cvs
   server <http://mitgcm.org/public/using_cvs.html>`__ and provides
   basic Matlab and python functionalities.

-  | A series of three presentations offered in May 2016 during the ECCO
     meeting at MIT provide an overview of the ECCO v4 r2 data sets and
     applications are available via researchgate.net
     (`doi.org/10.13140/RG.2.2.33361.12647 <http://doi.org/10.13140/RG.2.2.33361.12647>`__;
     `doi.org/10.13140/RG.2.2.26650.24001 <http://doi.org/10.13140/RG.2.2.26650.24001>`__;
   | `doi.org/10.13140/RG.2.2.36716.56967 <http://doi.org/10.13140/RG.2.2.36716.56967>`__).

.. _runs:

Running ECCO Version 4
**********************

This section explains how the ECCO version 4 setup is used to re-run the
release 2 state estimate over 1992–2011 (section
`2.1 <#eccov4-baseline>`__), other solutions (section
`2.2 <#eccov4-other>`__), short regression tests (section
`2.3 <#testreport>`__), or optimization tests (section
`2.4 <#optim>`__). Running MITgcm typically requires a linux cluster
with the following software: gcc, gfortran (or alternatives), mpi (for
parallel computation) and netcdf (for ‘pkg/profiles’). The `MITgcm
howto <http://mitgcm.org/public/devel_HOWTO/devel_HOWTO.pdf>`__ and
`MITgcm
manual <http://mitgcm.org/public/r2_manual/latest/online_documents/manual.pdf>`__
provide additional information.

For users who may lack on-premise resources or IT support, an automated
recipe which leverages Amazon Web Services’ cfncluster technology and
sets up a complete computational environment in the cloud (hardware,
software, model, and inputs) is provided in the
`example_scripts/ <https://github.com/gaelforget/ECCO_v4_r2/tree/master/example_scripts/>`__
directory (under `ECCO v4
r2 <https://github.com/gaelforget/ECCO_v4_r2/>`__ in github). In a
January 2017 test, it ran the 20 year solution on 96 vCPUs within 36h
for a cost of about 40$ using AWS’ spot instances.

.. raw:: latex

   \dirtree{%
   .1 MITgcm/.
   .2 model/ (core of MITgcm). 
   .2 pkg/ (MITgcm modules).
   %.2 verification/.
   %.3 testreport (shell script).
   %.3 aim.5l\_cs (mitgcm regression test).
   %.3 + global\_oce\_cs32/
   %.3 + global\_oce\_llc90/
   %.3 + global\_oce\_input\_fields/
   %.3 hs94.128x64x5 (mitgcm regression test).
   %.3 ....
   .2 tools/.
   %.3 \href{http://mitgcm.org/viewvc/MITgcm/MITgcm/tools/genmake2?view=markup}{genmake2} (shell script).
   .3 genmake2 (shell script).
   .3 build\_options (wrt compilers).
   .3 ....
   .2 mysetups/ (user created).
   .3 ECCO\_v4\_r2/.
   .4 build/.
   .4 code/.
   .4 input/.
   .4 input\_itXX/.
   .4 results\_itXX/.
   .4 forcing\_baseline2/ (from wget).
   .4 inputs\_baseline2/ (from wget).
   .4 ....
   .3 ....
   .2 ....
   }

.. _eccov4-baseline:

The Release 2 Solution
----------------------

It is here assumed that MITgcm and ECCO v4 directories have been
downloaded and organized as shown in
Fig. \ `[mitgcmdirs] <#mitgcmdirs>`__. Users can then re-run the ECCO
version 4 release 2 solution by following the directions in
Fig. \ `[baseline] <#baseline>`__. Afterwards they are strongly
encouraged to verify their results by using the included
testreport_ecco.m Matlab script as depicted in
Fig. \ `[testreportecco] <#testreportecco>`__. The expected level of
accuracy for 20-year re-runs, based upon an up-to-date MITgcm code and a
standard computing environment, is reached when the displayed values are
all :math:`\leq-3`. Interpretation of the testreport_ecco.m output is
explained in detail in :raw-latex:`\cite{gmd-8-3071-2015}`.

The 20-year model run typically takes between 6 to 12 hours of
wall-clock time on 96 cores using a modern computing environment. The
number of cores is 96 by default as reflected by
Fig. \ `[baseline] <#baseline>`__ but can be reduced to 24 simply by
copying ‘ECCO_v4_r2/code/SIZE.h_24cores’ over ‘ECCO_v4_r2/code/SIZE.h’
before compiling the model and then running it with ‘-np 24’ rather than
‘-np 96’ in Fig. \ `[baseline] <#baseline>`__. However, it should be
noted that reducing the number of cores increases wall-clock time and
memory requirements.

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

::


    cd MITgcm/mysetups/ECCO_v4_r2
    matlab -nodesktop -nodisplay

    %addpath ~/Documents/MATLAB/gcmfaces;
    %gcmfaces_global;

    addpath results_itXX;%add necessary .m and .mat files to path
    mytest=testreport_ecco('run/');%compute tests and display results

::


    --------------------------------------------------------------
           &   jT &   jS &      ... &  (reference is)
    run/   & (-6) & (-6) &      ...  &  baseline2      
    --------------------------------------------------------------

[testreportecco]

.. raw:: latex

   \clearpage

.. _eccov4-other:

Other 20-Year Solutions
-----------------------

It is here assumed that MITgcm and ECCO v4 directories have been
downloaded and organized as shown in
Fig. \ `[mitgcmdirs] <#mitgcmdirs>`__. Users can then re-run the
‘baseline 1’ solution that more closely matches the original, release 1,
solution of :raw-latex:`\cite{gmd-8-3071-2015}`. However, to re-run
baseline 1 instead of release 2, a few modifications to the setup are
needed: (a) download the corresponding forcing fields as follows:

::

    wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release1/forcing_baseline1/

(b) before compiling the model: define ‘ALLOW_KAPGM_CONTROL_OLD’ and
‘ALLOW_KAPREDI_CONTROL_OLD’ in ‘ECCO_v4_r2/code/GMREDI_OPTIONS.h’;
define ‘ALLOW_AUTODIFF_INIT_OLD’ in
‘ECCO_v4_r2/code/AUTODIFF_OPTIONS.h’; (c) before running the model: copy
‘ECCO_v4_r2/input_itXX/data’ and ‘data.exf’ over ‘ECCO_v4_r2/input/data’
and ‘data.exf’.

Users who may want to reproduce ‘release1’ even more precisely than
‘baseline1’ does should contact ecco-support@mit.edu to obtain
additional model inputs. Users holding a
`TAF <http://www.fastopt.de/>`__ license can also: (a) compile the
adjoint by replacing ‘make -j 4’ with ‘make adall -j 4’ in
Fig. \ `[baseline] <#baseline>`__; (b) activate the adjoint by setting
‘useAUTODIFF=.TRUE.,’ in data.pkg; (c) run the adjoint by replacing
‘mitgcmuv’ with ‘mitgcmuv_ad’ in Fig. \ `[baseline] <#baseline>`__.

.. _testreport:

Short Forward Tests
-------------------

To ensure continued compatibility with the up to date MITgcm, the ECCO
v4 model setup is also tested on a daily basis using the MITgcm’s
testreport command line utility (indicated in
Fig.\ `[mitgcmdirs] <#mitgcmdirs>`__) that compares re-runs with
reference results over a few time steps (see below for guidance and `the
MITgcm howto <http://mitgcm.org/public/devel_HOWTO/devel_HOWTO.pdf>`__
for additional details). These tests use dedicated versions of the ECCO
v4 model setup which are located within
`MITgcm_contrib/verification_other/ <http://mitgcm.org/viewvc/MITgcm/MITgcm_contrib/verification_other/>`__.

`global_oce_llc90/ <http://mitgcm.org/viewvc/MITgcm/MITgcm_contrib/verification_other/global_oce_llc90/>`__
(595M) uses the same LLC90 grid as the production ECCO v4 setup does
(section `2.1 <#eccov4-baseline>`__). Users are advised against running
forward tests using fewer than 12 cores (96 for adjoint tests) to avoid
potential memory overloads.
`global_oce_cs32/ <http://mitgcm.org/viewvc/MITgcm/MITgcm_contrib/verification_other/global_oce_cs32/>`__
(614M) uses the much coarser resolution CS32 grid and can thus be used
on any modern laptop. Instructions for their installation are provided
in `this
README <http://mitgcm.org/viewvc/*checkout*/MITgcm/MITgcm_contrib/verification_other/global_oce_llc90/README>`__
and `that
README <http://mitgcm.org/viewvc/*checkout*/MITgcm/MITgcm_contrib/verification_other/global_oce_cs32/README>`__,
respectively. Once installed, the smaller setup for instance can be
executed on one core by typing:

::

    cd MITgcm/verification/
    ./testreport -t global_oce_cs32

If everything proceeds as expected then the results are reported to
screen as shown in Fig. `[report] <#report>`__. The daily results of the
regression tests (ran on the ‘glacier’ cluster) are reported `on this
site <http://mitgcm.org/public/testing.html>`__. On other machines the
degree of agreement (16 digits in Fig. `[report] <#report>`__) may vary
and testreport may indicate ‘FAIL’. Note: despite the seemingly dramatic
character of this message, users may still be able to reproduce 20-year
solutions with acceptable accuracy (section `2.1 <#eccov4-baseline>`__).
To test
`global_oce_llc90/ <http://mitgcm.org/viewvc/MITgcm/MITgcm_contrib/verification_other/global_oce_llc90/>`__
using 24 processors and gfortran the corresponding command typically is:

::

    cd MITgcm/verification/
    ./testreport -of ../tools/build_options/linux_amd64_gfortran \
    -j 4 -MPI 24 -command 'mpiexec -np TR_NPROC ./mitgcmuv' \
    -t global_oce_llc90

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

Running the adjoint tests associated with
section \ `2.3 <#testreport>`__ requires: (1) a
`TAF <http://www.fastopt.de/>`__ license; (2) to soft link ‘code’ as
‘code_ad’ in
`global_oce_cs32/ <http://mitgcm.org/viewvc/MITgcm/MITgcm_contrib/verification_other/global_oce_cs32/>`__
and
`global_oce_llc90/ <http://mitgcm.org/viewvc/MITgcm/MITgcm_contrib/verification_other/global_oce_llc90/>`__.
Users that hold a TAF license can then further proceed with the
iterative optimization test case in
`global_oce_cs32/input_OI/ <http://mitgcm.org/viewvc/MITgcm/MITgcm_contrib/verification_other/global_oce_cs32/input_OI>`__.
Here the ocean model is replaced with a simple diffusion equation.

.. raw:: latex

   \smallskip

The pre-requisites are:

#. run the adjoint benchmark in
   `global_oce_cs32/ <http://mitgcm.org/viewvc/MITgcm/MITgcm_contrib/verification_other/global_oce_cs32/>`__
   via testreport (see section `2.3 <#testreport>`__).

#. Go to MITgcm/lsopt/ and compile (see section 3.18 of
   `manual <http://mitgcm.org/public/r2_manual/latest/online_documents/manual.pdf>`__).

#. Go to MITgcm/optim/, replace ‘natl_box_adjoint’ with
   ‘global_oce_cs32’ in `this
   Makefile <http://mitgcm.org/viewvc/MITgcm/optim/Makefile>`__, and
   compile as explained in section 3.18 of
   `manual <http://mitgcm.org/public/r2_manual/latest/online_documents/manual.pdf>`__.
   An executable named ‘optim.x’ should get created in MITgcm/optim. If
   otherwise, please contact mitgcm-support@mit.edu

#. go to MITgcm/verification/global_oce_cs32/input_OI/ and type ‘source
   ./prepare_run’

.. raw:: latex

   \smallskip

To match the reference results reported in `this
file <http://mitgcm.org/viewvc/*checkout*/MITgcm/MITgcm_contrib/verification_other/global_oce_cs32/input_OI/README>`__,
users should proceed as follows

#. ./mitgcmuv_ad :math:`>` output.txt

#. ./optim.x :math:`>` op.txt

#. increment optimcycle by 1 in data.optim

#. go back to step #1 to run the next iteration

#. type ‘grep fc costfunction000\*’ to display results

.. raw:: latex

   \clearpage

.. raw:: latex

   \newpage

.. [1]
   Throughout this document links are indicated by blue colored font.
