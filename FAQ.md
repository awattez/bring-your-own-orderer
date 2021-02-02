Extract of https://hyperledger-fabric.readthedocs.io/en/latest/Fabric-FAQ.html  



- *Question*:	**What is the orderer system channel?** 
- *Answer*:	The orderer system channel (sometimes called ordering system channel) is the channel the orderer is initially bootstrapped with. It is used to orchestrate channel creation. The orderer system channel defines consortia and the initial configuration for new channels. At channel creation time, the organization definition in the consortium, the /Channel group’s values and policies, as well as the /Channel/Orderer group’s values and policies, are all combined to form the new initial channel definition