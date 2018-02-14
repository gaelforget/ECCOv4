# ECCO version 4

**Content:**

This repository contains model settings ([code/](code/), [input/](input/)) and documentation ([readthedocs](http://eccov4.readthedocs.io/en/latest/)) that allow users to download, analyze, rerun, or modify ECCO version 4 ocean state estimates using the [MITgcm](http://mitgcm.org/) via on-premise cluster or via Amazon Web Services (see [example_scripts/](example_scripts/)). The master branch is based the ECCO version 4 release 2 solution (see below). If user support is needed, please contact <mitgcm-support@mit.edu> or <ecco-support@mit.edu>.


**Citation for this repository:**

[![DOI](https://zenodo.org/badge/76184688.svg)](https://zenodo.org/badge/latestdoi/76184688)

[Estimating the Circulation and Climate of the Ocean]: http://ecco-group.org/
[MIT general circulation model]: http://mitgcm.org/
[Amazon Web Services' cfncluster]: https://aws.amazon.com/hpc/cfncluster/
[the Harvard dataverse]: https://dataverse.harvard.edu/dataverse/ECCOv4r2
[gcmfaces]: https://github.com/gaelforget/gcmfaces
[MITprof]: https://github.com/gaelforget/MITprof
[the ECCO servers]: http://ecco-group.org/products.htm
[direct download]: https://dspace.mit.edu/bitstream/handle/1721.1/102062/standardAnalysis.pdf

**ECCO version 4 release 2:** 

[Estimating the Circulation and Climate of the Ocean][] version 4 release 2 is an ocean state estimate and solution of the [MIT general circulation model][] that covers the period from 1992 to 2011 (Forget et al., 2016). It is a minor update of the original ECCO version 4 solution (Forget et al., 2015) that benefits from a few additional corrections listed in Forget et al. (2016) and is easier to analyze and re-run. Its input and output are distributed via [the ECCO servers][] and permanently archived via [the Harvard dataverse][]. They can be analyzed and manipulated using e.g. the [gcmfaces][] and [MITprof][] toolboxes.

**References:**

Forget, G., J.-M. Campin, P. Heimbach, C. N. Hill, R. M. Ponte, and C. Wunsch, 2015: ECCO version 4: an integrated framework for non-linear inverse modeling and global ocean state estimation. Geoscientific Model Development, 8, 3071-3104, <http://dx.doi.org/10.5194/gmd-8-3071-2015>, <http://www.geosci-model-dev.net/8/3071/2015/>

Forget, G., J.-M. Campin, P. Heimbach, C. N. Hill, R. M. Ponte, and C. Wunsch, 2016: ECCO Version 4: Second Release, <http://hdl.handle.net/1721.1/102062>, [direct download][]

