const fs = require('fs');

const toTS = (date) => {
  return Math.floor(new Date(date).valueOf() / 1000);
};
const showEvents = (receipt) => {
  if (receipt.events) {
    console.log(
      "events",
      receipt.events.map(({ eventSignature, args }) => ({
        eventSignature,
        args,
      }))
    );
  } else {
    console.log("No events");
    console.log(receipt);
  }
};
const main = async () => {
  //#region get signers
  const [myAddress, randomAddress, random2Address] =
    await hre.ethers.getSigners();
  console.log("myaddress is :", myAddress.address);
  console.log("random address is :", randomAddress.address);
  console.log({ random2address: random2Address.address });
  //#endregion
  //#region Deploy the contract
  console.log(
    "Deploy the contract------------------------------------------------------"
  );
  const LeaseContract = await hre.ethers.getContractFactory("TimeLimitedToken");
  const leaseContract = await LeaseContract.deploy();
  await leaseContract.deployed();
  const gas = await leaseContract.deployTransaction;
  const check = await leaseContract.deployTransaction.wait();
  console.log("Gas Used: ", check.gasUsed);
  console.log("Total wei for gas", gas.gasPrice);
  console.log("Contract deployed to:", leaseContract.address);
  let config = `export const contractAddress = "${leaseContract.address}";`;
  let data = JSON.stringify(config);
//   fs.writeFileSync('./roberts/lease/config.js', JSON.parse(data));

  console.log(
    "END Deploy contract------------------------------------------------------"
  );
  //#endregion
  //#region define functions based on the contract
  const lease = async (address, token, start, end, runAs) => {
    const startTS = toTS(start);
    const endTS = toTS(end);
    console.log("Runing lease with ", address, token, startTS, endTS);
    let receipt;
    if(!runAs){
    console.log("Running as random address");
    receipt = await leaseContract[
      "lease(address,uint256,uint256,uint256)"
    ](address, token, startTS, endTS);
    }
    else{
    console.log("Running as: ", runAs.address);
    receipt = await leaseContract.connect(runAs)[ "lease(address,uint256,uint256,uint256)"
    ](address, token, startTS, endTS)
    } 
    const rct = await receipt.wait();
    showEvents(rct);
  };
  const getLeases = async (tokenId) => {
    leaseContract["getLeases(uint256)"](tokenId);
  };
  //endregion
  //#region Mint the asset
  console.log(
    "Mint the Asset------------------------------------------------------"
  );
  const txn = await leaseContract.connect(randomAddress).mintAsset("Home", "AirBNB ", "NO IMAGE");
//   console.log("we here",txn);
  const receipt = await txn.wait();
  const mint2 = await leaseContract.mintAsset("TEST", "AirBNB ", "NO IMAGE");
  const receipt2 = await mint2.wait();

  showEvents(receipt);
  showEvents(receipt2);

  
    try{
      const lease1 = await lease(myAddress.address, 1, "2022-05-01", "2022-06-01", myAddress);
    }
    catch(e){
        console.log(e);
    }
    const approved_tx = await leaseContract.connect(randomAddress).approveLease(myAddress.address, 1, toTS("2022-05-01"), toTS("2022-06-01"));
    const receipt5 = await approved_tx.wait();
    showEvents(receipt5);
    try{
      const lease1 = await lease(myAddress.address, 1, "2022-05-01", "2022-06-01", myAddress);
    }
    catch(e){
        console.log(e);
    }
//   const startTS = toTS("2022-05-01");
//   const endTS = toTS("2022-06-01");
//   const receipt3 = await leaseContract.connect(myAddress)[ "lease(address,uint256,uint256,uint256)"
//   ](myAddress.address, 2, startTS, endTS)
//   const receipt4 = await receipt3.wait();
//   showEvents(receipt4);
    
    
    /*
  const nullLease = await getLeases(1);
  console.log("Leases when there is nothing leased ", nullLease);
  console.log(
    "Lease on 5/1/2022",
    await leaseContract.getLease(1, toTS("2022-05-01"))
  );
  console.log(
    "Lessee on 5/1/2022",
    await leaseContract.lesseeOf(1, toTS("2022-05-01"))
  );
  console.log(
    "Possessor on 5/1/2022",
    await leaseContract.possessorOf(1, toTS("2022-05-01"))
  );
  console.log(
    "END Mint the asset------------------------------------------------------"
  );
  //#endregion
  //#region Initial lease
  console.log(
    "Lease the asset to me------------------------------------------------------"
  );
  const startDate = new Date("2022-04-25T00:00:00.000Z");
  const endDate = new Date("2022-05-28T00:00:00.000Z");
  await lease(myAddress.address, 1, startDate, endDate);
  const leases = await getLeases(1);
  console.log("Leases for tokenid 1 are:", leases);

  //get lease end

  // const start = await leaseContract.getLeaseStart(1, )
  const end = await leaseContract.getLeaseEnd(1, toTS("2022-04-26"));
  console.log("Lease end date is: ", new Date(end * 1000).toLocaleString());

  // this will not show an address for a lessee since its not leased during the timestamp passed in
  const lessee = await leaseContract.lesseeOf(1, toTS("2022-03-31"));
  console.log("Lessee on 3/31", lessee);

  // this should show an address for a lessee
  const lessee_2 = await leaseContract.lesseeOf(1, toTS("2022-04-30"));
  console.log("Lessee on 4/30", lessee_2);
  console.log(
    "END Lease the asset to me------------------------------------------------------"
  );
  //#endregion
  const isLease_2 = await leaseContract.isLeaseAvailable(
    1,
    toTS("2022-04-10"),
    toTS("2022-04-15")
  );
  console.log("lease available 4/10-4/15: ", isLease_2);

  const isLease_3 = await leaseContract.isLeaseAvailable(
    1,
    toTS("2022-06-10"),
    toTS("2022-06-15")
  );
  console.log("lease available 6/10-6/15: ", isLease_3);

  // not useful so far
  const isLease_1 = await leaseContract.isLeaseAvailable(
    1,
    toTS("2022-03-10"),
    toTS("2022-03-15")
  );
  console.log("lease available 3/10-3/15: ", isLease_1);

  const txn3 = await lease(
    randomAddress.address,
    1,
    "2022-05-01",
    "2022-05-15"
  );

  const l510_lessee = await leaseContract.lesseeOf(1, toTS("2022-05-10"));
  console.log({ l510_lessee });

  const l516_lessee = await leaseContract.lesseeOf(1, toTS("2022-05-16"));
  console.log({ l516_lessee });
  return;
  // NOT USEFUL RN
  // const isLease2 = await leaseContract.isLeaseAvailable(1, 74, 79);
  // console.log({isLease2});

  const daysTaken2 = await leaseContract.daysTaken(1, 74);
  console.log({ daysTaken2 });

  const leases7 = await leaseContract["getLeases(uint256)"](1);
  console.log({ leases7 });

  const txn4 = await leaseContract["lease(address,uint256,uint256,uint256)"](
    random2Address.address,
    1,
    186,
    190
  );
  await txn4.wait();

  const leases8 = await leaseContract["getLeases(uint256)"](1);
  console.log({ leases8 });

  const assets = await leaseContract.getAssets(1);
  console.log({ assets });
  const timestamp = 1640970000 + 43200;
  const datestring = new Date(timestamp * 1000).toLocaleString();
  console.log({ datestring });
  /** */
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

