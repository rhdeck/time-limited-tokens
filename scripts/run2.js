const main = async () => {
    
    const LeaseContract = await hre.ethers.getContractFactory('TimeLimitedToken');
    const leaseContract = await LeaseContract.deploy();
    await leaseContract.deployed();
    const gas = await leaseContract.deployTransaction;
    const check = await leaseContract.deployTransaction.wait()
    console.log("Gas Used: " + check.gasUsed)
    console.log(Number(gas.gasPrice))
    console.log("Contract deployed to:", leaseContract.address);
  
    // Minting the asset
    const txn = await leaseContract.mintAsset("Home", "AirBNB ", "NO IMAGE");
    
    const receipt = await txn.wait();
    // console.log(receipt.events)
    // receipt.events.find(x => {
    //     x.event === "AssetMinted";
    //     console.log(x.args.tokenURI);
    // })

  const [myAddress, randomAddress, random2Address] = await hre.ethers.getSigners();
  //leasing the asset
  // console.log(leaseContract)
  console.log("Leasing here");  
  console.log("myaddress is :", myAddress.address);
  console.log("random address is :", randomAddress.address);
  console.log({random2address:random2Address.address});
  const txn2 = await leaseContract['lease(address,uint256,uint256,uint256)'](myAddress.address, 1, 150, 200);
  console.log("Finished leasing")
  await txn2.wait()
  
  // console.log(leaseContract)
  const leases = await leaseContract['getLeases(uint256)'](1)
  console.log("Leases for tokenid 1 are:", leases)

  //get lease end
  
  // const start = await leaseContract.getLeaseStart(1, )
  const end = await leaseContract.getLeaseEnd(1, 1647018000)
  console.log("Lease end date is: ", end)
  
  // this will not show an address for a lessee since its not leased during the timestamp passed in
  const lessee = await leaseContract.lesseeOf(1,1647018000)
  console.log(lessee)

  // this should show an address for a lessee
  const lessee_2 = await leaseContract.lesseeOf(1,1658250000)
  console.log(lessee_2)
  
  // const isLease_2 = await leaseContract.isLeaseAvailable(1, 150, 175);
  // console.log("lease available: ",isLease_2)
  
  // not useful so far
  // const isLease_1 = await leaseContract.isLeaseAvailable(1, 78, 79);
  // console.log("lease available: ",isLease_1)

  

  const daysTaken = await leaseContract.daysTaken(1,74)
  console.log(daysTaken)  
  // console.log(leaseContract)
  const txn3 = await leaseContract['lease(address,uint256,uint256,uint256)'](randomAddress.address, 1, 175, 180);
  await txn3.wait();
  
  const lessee_3 = await leaseContract.lesseeOf(1,1658250000)
  console.log(lessee_3)  
  
  const lessee2 = await leaseContract.lesseeOf(1,end)
  console.log({lessee2});
  
  // NOT USEFUL RN
  // const isLease2 = await leaseContract.isLeaseAvailable(1, 74, 79);
  // console.log({isLease2});

  const daysTaken2 = await leaseContract.daysTaken(1,74)
  console.log({daysTaken2});

  const leases7 = await leaseContract['getLeases(uint256)'](1)
  console.log({leases7});

    const txn4= await leaseContract['lease(address,uint256,uint256,uint256)'](random2Address.address, 1, 186, 190);
    await txn4.wait();

  const leases8 = await leaseContract['getLeases(uint256)'](1)
  console.log({leases8});

  const assets = await leaseContract.getAssets(1);
  console.log({assets});
  const timestamp = 1640970000 +43200
  const datestring = new Date(timestamp*1000).toLocaleString();
  console.log({datestring});

  };
  
  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();
  