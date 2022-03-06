const main = async () => {
    const polySwap = await hre.ethers.getContractFactory('AkshayLease');
    const leaseContract = await polySwap.deploy();
    await leaseContract.deployed();
    const gas = await leaseContract.deployTransaction;
    const check = await leaseContract.deployTransaction.wait()
    console.log("Gas Used: " + check.gasUsed)
    console.log(Number(gas.gasPrice))
    console.log("Contract deployed to:", leaseContract.address);
  
  const txn = await leaseContract.mintAsset("Home", "AirBNB ", "NO IMAGE");
  
  const receipt = await txn.wait();
  
  receipt.events.find(x => {
    x.event === "AssetMinted";
    console.log(x.args.tokenURI);
  })

  const myAddress = await hre.ethers.getSigners();
  
  const txn2 = await leaseContract.lease(myAddress.address, 1, 70, 75);
  
  await txn2.wait()
  const leases = await leaseContract.getLeases(1)
  console.log(leases)
  
  const end = await leaseContract.getLeaseEnd(1, 1647018000)
  
  console.log(end)
  
  const lessee = await leaseContract.lesseeOf(1,1647018000)
  const isLease = await leaseContract.isLeaseAvailable(1, 74, 79, 0);
  const daysTaken = await leaseContract.daysTaken(1,74)
  
  console.log(daysTaken)
  console.log(lessee)
  console.log(isLease)
  
  await leaseContract.transferLease(1, 72, 73, "0x381D1a3c6Aa1Ed4AE2834fCFA30c34825eB87Ca4");
  
  const lessee2 = await leaseContract.lesseeOf(1,end)
  const isLease2 = await leaseContract.isLeaseAvailable(1, 74, 79, 0);
  const daysTaken2 = await leaseContract.daysTaken(1,74)
  
  console.log(daysTaken2)
  console.log(lessee2)
  console.log(isLease2)
  
  const leases7 = await leaseContract.getLeases(1)
  console.log(leases7)
  
  const assets = await leaseContract.getAssets(1);
  console.log(assets)
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
  