
To set up MITgcm to reproduce the ECCO version 4 baseline 1 solution, which most closely matches the ECCO version 4 release 1 solution of [FCH+15], follow directions provided at [http://eccov4.readthedocs.io/]() to install the ECCO version 4 release 2 model setup, and then modify it as follows:

1. add ``#define ALLOW_KAPGM_CONTROL_OLD`` and ``#define ALLOW_KAPREDI_CONTROL_OLD`` in ``code/GMREDI_OPTIONS.h``
2. add ``#define ALLOW_AUTODIFF_INIT_OLD`` in ``code/AUTODIFF_OPTIONS.h``.
3. copy ``input_itXX/data`` and ``input_itXX/data.exf`` over ``input/data`` and ``input/data.exf``, respectively.

To compile MITgcm and run the ECCO version 4 baseline 1 solution, then follow directions provided at [http://eccov4.readthedocs.io/]() except that the ECCO version 4 baseline 1 forcing ([forcing_baseline1/](<ftp://mit.ecco-group.org/ecco_for_las/version_4/release1/forcing_baseline1/>)) should be linked in the `run/` directory in place of `forcing_baseline2/`.



