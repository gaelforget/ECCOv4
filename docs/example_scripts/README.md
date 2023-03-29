# Using cfncluster to run ECCO v4 r2

[This file][] provides a recipe to run ECCO v4 r2 (Forget et al. 2015, 2016) using [MITgcm][] and [cfncluster][]. It relies on an AWS EBS volume snapshot for providing model intputs (snap-03a927d31811042e1 at the time of writing) and the [ECCO v4 r2 github repository][] for providing model setup and installation scripts (see [eccov4.pdf][] for additional documentation). An alternative recipe that uses [starcluster][] instead of [cfncluster][] is also available @ <https://github.com/CamClimate/ECCO-cloud>. For user support, if needed, contact <mitgcm-support@mit.edu> or <ecco-support@mit.edu>. Citation for this repository: 

[![DOI](https://zenodo.org/badge/76184688.svg)](https://zenodo.org/badge/latestdoi/76184688)


[eccov4.pdf]: https://github.com/gaelforget/ECCO_v4_r2/blob/master/eccov4.pdf
[This file]: https://github.com/gaelforget/ECCO_v4_r2/blob/master/docs/example_scripts/README.md
[ECCO v4 r2 github repository]: https://github.com/gaelforget/ECCO_v4_r2
[gcmfaces]: https://github.com/gaelforget/gcmfaces

[cfncluster documentation]: http://cfncluster.readthedocs.io/en/latest/
[cfncluster]: https://aws.amazon.com/hpc/cfncluster/
[cfncluster software]: http://cfncluster.readthedocs.io/en/latest/
[starcluster]: http://star.mit.edu/cluster/

[MITgcm]: http://mitgcm.org/
[MIT general circulation model]: http://mitgcm.org/
[Estimating the Circulation and Climate of the Ocean]: http://ecco-group.org/

### Important warning:  
Before proceeding any further, users are advised to learn about AWS pricing policies and spot instances (<https://aws.amazon.com/ec2/pricing/>, <https://aws.amazon.com/ebs/pricing/>, etc.) as well as about cfncluster and its configuration (<http://cfncluster.readthedocs.io/en/latest/index.html>). The cluster created via steps 1 and 2 below consists of one master instance (on-demand; m4.large) and six compute instances (spot; c4.4xlarge). In a January 2017 test, such a cluster ran the 20 year solution on 96 vCPUs within 36h for a cost of about 40US$ with a spot instance bid of 0.20US$ (`spot_price = 0.20` in the `.cfncluster/config` file created in step 1). However, AWS costs can vary widely with location and time. Users should therefore make sure to evaluate AWS charges and spot instance prices for themselves before creating any cluster (step 2). They should also make sure to delete used clusters to stop paying AWS charges (see step 7). 


## Instructions

### Step 1:  
- Using the AWS console, launch a micro-instance of the Amazon Linux AMI (e.g., ami-a4c7edb2 at time of writing) and **log into this micro-instance**.
- install software and set-up the [cfncluster software][] for ECCO v4 r2:  
`sudo yum -y install git`  
`git clone https://github.com/gaelforget/ECCO_v4_r2`  
`source ./ECCO_v4_r2/docs/example_scripts/setup_cfncluster.sh`  
- Information provided by the user gets stored in the .cfncluster/config file and will be used by cfncluster to launch the cluster of instances.  


### Step 2:  
- To **create the cluster** (e.g., mycluster1), type `cfncluster create mycluster1`
- This process launches the master and compute instances according to the .cfncluster/config specifications. Instances launched by cfncluster can be monitored via the AWS console.  
- The cluster creation process may take 30 minutes or more. To verify that the process completed successfully, type `cfncluster status mycluster1` afterwards.

### Step 3:
- At this point, please **log out of the micro-instance** from step 1. It can be stopped but will be needed to delete the cluster in step 7.
- To proceed with steps 4-6, **log into the master instance** as indicated in the AWS console. 

### Step 4:
- To **prepare the ECCO v4 r2 model run**, execute the following commands:  
	`cd /shared`  
	`git clone https://github.com/gaelforget/ECCO_v4_r2`  
	`source ./ECCO_v4_r2/docs/example_scripts/setup_MITgcm.sh`  
- The above command installs and compiles the MITgcm ECCO v4 r2 setup.

### Step 5:
- To **run ECCO v4 r2 on 96 vCPUs** via the SGE queuing system, type:  
`qsub -pe mpi 96 ./ECCO_v4_r2/docs/example_scripts/run_eccov4r2.sh`
- During the model run, cluster activity can be monitored using `qhost` and `qstat` at the command line or via the AWS console (see `screenshot-compute.png` for an example).
- The model run normally proceeds from 1992 to 2011 and may take about 8 min to simulate 1 month. Progress can be monitored by e.g. typing `ls -1 /shared/run/diags/state_2d_set1.0*data` to display the list of completed monthly files at any given point in time.
- Once the model run has completed, there should be 240 `state_2d_set1.0*data` files, `qstat` should return an empty list, and `tail run/STDOUT.0000` should conclude with **PROGRAM MAIN: Execution ended Normally**.

### Step 6:
- The [gcmfaces][] Matlab toolbox provides extensive capabilities to analyze model output generated in step 5. It is freely available for download @ <https://github.com/gaelforget/gcmfaces/>.
- Users can transfer results to their on-premise storage or store them in the cloud using e.g. an AWS EBS volume snapshot (e.g., snap-04346380ccc292134 at the time of writing) but should keep in mind that **such operations generally incur additional AWS charges**.


### Step 7:
- **To stop paying for their clusters, e.g. mycluster1, users should make sure delete it by typing** `cfncluster delete mycluster1` in the micro-instance from step 1.
- To verify that all clusters have been deleted, type `cfncluster list` and refer to the AWS console where all cluster instances should have disappeared or be indicated as "terminated".
- Once all clusters have been deleted, the **micro-instance from step 1 should also be terminated**.


## References

ECCO v4 r2 ([Estimating the Circulation and Climate of the Ocean][], version 4, release 2) is an ocean state estimate and solution of the MITgcm ([MIT general circulation model][]) that covers the period from 1992 to 2011 (Forget et al., 2016). It is a minor update of the original ECCO v4 solution (Forget et al., 2015) that benefits from a few additional corrections listed in Forget et al. (2016) and is easier to analyze and re-run. It is permanently archived via dataverse @ <https://dataverse.harvard.edu/dataverse/ECCOv4r2> and available via ftp @ <ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/>

Forget, G., J.-M. Campin, P. Heimbach, C. N. Hill, R. M. Ponte, and C. Wunsch, 2015: ECCO version 4: an integrated framework for non-linear inverse modeling and global ocean state estimation. Geoscientific Model Development, 8, 3071-3104, http://dx.doi.org/10.5194/gmd-8-3071-2015, <http://www.geosci-model-dev.net/8/3071/2015/>

Forget, G., J.-M. Campin, P. Heimbach, C. N. Hill, R. M. Ponte, and C. Wunsch, 2016: ECCO Version 4: Second Release, http://hdl.handle.net/1721.1/102062, <https://dspace.mit.edu/bitstream/handle/1721.1/102062/standardAnalysis.pdf?sequence=1>


