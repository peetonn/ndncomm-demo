ndncomm-demo
============

This repo contains supporting scripts for setting up demo testing environment for NDN-Comm 2014. 


>**NOTE:** This repo depends on https://github.com/peetonn/ndnrtc-archive. In order to use demo scripts both repos should be checked out into the same folder.

Description
---
* **topology.pdf** - contains demo stand topology description; each node has abbreviation (i.e. NFD-1, Demo-2, etc.);
* **demo-mappings.txt** - contains pairs "identifier=identifier" which establish mappings between abbreviation from topology.pdf and real IP address or a name from hubs.txt ([ndnrtc-archive repo](https://github.com/peetonn/ndnrtc-archive/blob/master/hubs.txt));
* **setup-demo.py** - should be executed every time when demo-mappings.txt is updated; this script updates setup-nfd.sh script and configuration files for each producer/consumer involved in demo; once this script is executed, all the files are ready to be distributed among demo nodes;
* **setup-nfd.sh** - should be executed on nodes, participating in demo; sets NFD routes according to the node's role;
* **rundemo.sh** - should be executed on nodes (consumers or producers, not intermediate hubs!), participating in demo; launches demo app with configuration depending on arguments passed; for best experience - script should be executed from separate folder:
<pre>
$ mkdir demorun && cd demorun
$ ../rundemo demo1
</pre>
