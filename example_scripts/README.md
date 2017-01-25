#Using cfncluster to run ECCO v4 r2

[This file][] provides a recipe to run ECCO v4 r2 (Forget et al. 2015, 2016) using [MITgcm][] and [cfncluster][]. It relies on an AWS EBS volume snapshot for providing model intputs (snap-03a927d31811042e1 at the time of writing) and the [ECCO v4 r2 github repository][] for providing model setup and installation scripts (see [eccov4.pdf][] for additional documentation). For user support, if needed, contact <ecco-support@mit.edu> or <mitgcm-support@mit.edu>.

[eccov4.pdf]: https://github.com/gaelforget/ECCO_v4_r2/blob/master/eccov4.pdf
[This file]: https://github.com/gaelforget/ECCO_v4_r2/blob/master/example_scripts/README.md
[ECCO v4 r2 github repository]: https://github.com/gaelforget/ECCO_v4_r2


[cfncluster documentation]: http://cfncluster.readthedocs.io/en/latest/
[cfncluster]: https://aws.amazon.com/hpc/cfncluster/
[cfncluster software]: http://cfncluster.readthedocs.io/en/latest/

[MITgcm]: http://mitgcm.org/
[MIT general circulation model]: http://mitgcm.org/
[Estimating the Circulation and Climate of the Ocean]: http://ecco-group.org/

**important warning:**  
before proceeding any further, users are advised to learn about AWS pricing policies and spot instances (<https://aws.amazon.com/ec2/pricing/>, <https://aws.amazon.com/ebs/pricing/>, etc.) as well as cfncluster and its configuration (<http://cfncluster.readthedocs.io/en/latest/index.html>). The cluster created via steps 1 and 2 below consists of one master instance (on-demand; m4.large) and six compute instances (spot; c4.4xlarge). Costs to the user may exceed several dollars per hour even when using spot instances. Users should make sure to (1) evaluate AWS costs for themselves before creating any cluster and (2) always delete clusters to stop paying AWS charges (see step 7). 


##Instructions

###step 1:  
- using the AWS console, launch a micro-instance of the Amazon Linux AMI (ami-9be6f38c at time of writing); **log into this micro-instance** and install the [cfncluster software][]:  
`sudo yum -y update`  
`sudo pip install cfncluster`  
- to download a cfncluster config file template for ECCO v4 r2, type:  
`sudo yum -y install git`  
`git clone https://github.com/gaelforget/ECCO_v4_r2`  
`mkdir .cfncluster`
`cp ECCO_v4_r2/example_scripts/config.step2 .cfncluster/config`

###step 2:  
- to allow cfncluster to launch instances, type `cfncluster configure` and provide user information as prompted; cfncluster will edit this infomation in the .cfncluster/config template.  
- to **create the cluster (e.g., mycluster1)**, type `cfncluster create mycluster1`
- this process launches the master and compute instances according to the .cfncluster/config specifications. Instances launched by cfncluster can be monitored via the AWS console.  
- the cluster creation process may take 30 minutes or more. To verify that the process completed successfully, type `cfncluster status mycluster1` afterwards.

###step 3:
- at this point, please **log out of the micro-instance** from step 1. It can be stopped but will be needed to delete the cluster in step 7.
- to proceed with steps 4-6, **log into the master instance** as indicated in the AWS console. 

###step 4:
- to **prepare the ECCO v4 r2 model run**, execute the following commands:  
	`cd /shared`  
	`git clone https://github.com/gaelforget/ECCO_v4_r2`  
	`source ./ECCO_v4_r2/example_scripts/setup_rhel.sh`  
	`source ./setup_export.sh`  
	`source ./ECCO_v4_r2/example_scripts/setup_MITgcm.sh`  
- setup\_rhel.sh (1) updates software if needed and (2) generates setup\_export.sh; setup\_export.sh (3) defines environment variables that MITgcm relies on; setup\_MITgcm.sh (4) installs MITgcm, (5) compiles and runs a short test, and (6) compiles the ECCO v4 r2 model setup.

###step 5:
- to **run ECCO v4 r2 on 96 vCPUs** via the SGE queuing system, type:  
`qsub -pe mpi 96 ./ECCO_v4_r2/example_scripts/run_eccov4r2.sh`
- during the model run, cluster activity can be monitored using `qhost` and `qstat`. The model run normally proceeds from 1992 to 2011 and may take about 8 min to simulate 1 month. 
- once the model run is complete, `qstat` should return an empty list and `tail run/STDOUT.0000` conclude with **PROGRAM MAIN: Execution ended Normally**.

###step 6:
- _post-processing remains to be documented_

###step 7:
- **to stop paying for your cluster, e.g. mycluster1, make sure delete it by typing** `cfncluster delete mycluster1` in the micro-instance from step 1.
- to verify that all clusters have been deleted, type `cfncluster list` and refer to the AWS console where all cluster instances should have disappeared or be indicated as "terminated".
- once all clusters have been deleted, the **micro-instance from step 1 should also be terminated**.


##References

ECCO v4 r2 ([Estimating the Circulation and Climate of the Ocean][], version 4, release 2) is an ocean state estimate and solution of the MITgcm ([MIT general circulation model][]) that covers the period from 1992 to 2011 (Forget et al., 2016). It is a minor update of the original ECCO v4 solution (Forget et al., 2015) that benefits from a few additional corrections listed in Forget et al. (2016) and is easier to analyze and re-run. It is permanently archived via dataverse @ <https://dataverse.harvard.edu/dataverse/ECCOv4r2> and available via ftp @ <ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/>

Forget, G., J.-M. Campin, P. Heimbach, C. N. Hill, R. M. Ponte, and C. Wunsch, 2015: ECCO version 4: an integrated framework for non-linear inverse modeling and global ocean state estimation. Geoscientific Model Development, 8, 3071-3104, http://dx.doi.org/10.5194/gmd-8-3071-2015, <http://www.geosci-model-dev.net/8/3071/2015/>

Forget, G., J.-M. Campin, P. Heimbach, C. N. Hill, R. M. Ponte, and C. Wunsch, 2016: ECCO Version 4: Second Release, http://hdl.handle.net/1721.1/102062, <https://dspace.mit.edu/bitstream/handle/1721.1/102062/standardAnalysis.pdf?sequence=1>


