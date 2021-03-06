import Head from "next/head";
import React, { useEffect, useCallback, useState } from "react";
import DropdownButton from "react-bootstrap/DropdownButton";
import { useRouter } from "next/router";
import Link from "next/link";
import ModalMint from "../components/modal/modalMint";
import ModalAccess from "../components/modal/modalAccess";
import WalletConnectProvider from "@walletconnect/web3-provider";
import Web3Modal from "web3modal";
import thisABI from "../abi/TimeLimitedToken.json";
import { useEtherizer } from "./../components/Etherizer";
import { ethers } from "ethers";
// import { contractAddress } from '../config';
// import {
//   ContractsAppContext,
//   EthersAppContext,
//   useSignerChainId,
//   useBlockNumber,
//   useEthersContext,
// } from "eth-hooks";

const App = () => {
  const router = useRouter();
  // const {} = useEthersContext();
  console.log("GM");
  const { isConnected, provider, signer } = useEtherizer(); //@RHD This is where you can find your provider and signer from web3
  // const provider = new ethers.providers.InfuraProvider();
  const thisContract = '0x5FbDB2315678afecb367f032d93F642f64180aa3';
  const instance = new ethers.Contract(thisContract, thisABI.abi, provider);
  const [currentAccount, setCurrentAccount] = useState();
  const [loading, setLoading] = useState(false);
  const [instanceOne, setInstanceOne] = useState(instance);
  const [allAssets, setAllAssets] = useState();
  const [allLeases, setAllLeases] = useState();

  const convertDate = (date) => {
    const myDate = new Date(date);
    const myEpoch = myDate.valueOf() / 1000.0;
    return myEpoch;
  };

  const dateReadable = (time) => {
    const myDate = new Date(time);
    return myDate.toLocaleString('en-US', {timeZone: "UTC"});
  };


  const initialFormData = Object.freeze({
    dateOne: "",
    dateTwo: "",
    wallet: "",
  });

  const [formData, updateFormData] = useState(initialFormData);

  const handleChange = async (e) => {
    updateFormData({
      ...formData,

      [e.target.name]: e.target.value,
    });
  };

  const providerOptions = {
    walletconnect: {
      package: WalletConnectProvider,
      options: {},
    },
  };

  let web3Modal;

  async function init() {
    if (window !== undefined) {
      web3Modal = new Web3Modal({
        network: "rinkeby",
        cacheProvider: true,
        providerOptions,
      });

      web3Modal.show = true;
    }

    const instances = await web3Modal.connect();

    const provider = new ethers.providers.Web3Provider(instances);
    const signer = provider.getSigner();
  }

  const fetchAccountData = useCallback(async () => {
    const { ethereum } = window;

    let chainId;
    let accounts = [];

    if (ethereum) {
      // Get connected chain id from Ethereum node
      chainId = await ethereum.request({ method: "eth_chainId" });
      // Load chain information over an HTTP API

      // Get list of accounts of the connected wallet
      try {
        accounts = await ethereum.request({ method: "eth_accounts" });
      } catch (err) {
        console.log(err.message);
      }
      console.log(accounts, "accounts");
      // MetaMask does not give you all accounts, only the selected account
      if (accounts.length !== 0) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        console.log("signer: ", signer)
        const dappAddress = thisContract;
        const instanceTwo = new ethers.Contract(
          dappAddress,
          thisABI.abi,
          signer
        );
        setInstanceOne(instanceTwo);
        setCurrentAccount(accounts[0]);
        console.log("Got accounts", accounts);
      } else {
      }
    } else {
    }
  }, []);

  async function onConnect() {
    try {
      init();
      console.log("Opening a dialog", web3Modal);
    } catch (err) {
      console.log(err);
    }

    let provider;
    try {
      provider = await web3Modal.connect();
      window.location.reload();
    } catch (err) {
      console.log("Could not get a wallet connection", err);
    }
    // Subscribe to accounts change
    provider.on("accountsChanged", (accounts) => {
      fetchAccountData();
    });

    // Subscribe to networkId change
    provider.on("networkChanged", (networkId) => {
      fetchAccountData();
    });
  }

  const getAllAssets = useCallback(async () => {
    console.log("getallassets is running.");
    let assets = [];
    if (currentAccount) {
      for (let i = 1; i < 100000; i++) {
        try {

          const asset = await instanceOne.getAssets(i);
          const uri = Buffer.from(asset.substring(29), "base64").toString();
          const tokenDetails = JSON.parse(uri);
          tokenDetails.id = i;
          assets.push(tokenDetails);
        } catch (err) {
          console.log(err.message);
          break;
        }
      }
    }
    setAllAssets(assets);
  }, [currentAccount, instanceOne]);

  const getAllLeases = useCallback(async () => {
    console.log("getallleases is running.");
    let leases = [];
    let assets = [];
    if (currentAccount) {
      for (let i = 1; i <= allAssets.length; i++) {
        console.log(allAssets, " Allassets")
        for (let j = 0; j < 100000; j++) {
        try {
              console.log("Instance is :",instanceOne);
          const lease = await instanceOne.leasesByToken(i, j);
          leases.push(lease);
        } catch (err) {
          assets.push(leases)
          leases = [];
          console.log(err.message, " Lease error");
          break;
        }
      }
      }
    }
    setAllLeases(assets);
  }, [currentAccount, instanceOne, allAssets]);

  const lease = async (id) => {
    console.log("instance one: ", instanceOne);
    let dates1 = convertDate(formData.dateOne);
    let dates2 = convertDate(formData.dateTwo);
    // console.log()
    console.log("date1 is : ",dates1);
    // let dates1 = Number(convertDate(formData.dateOne));
    // let dates2 = Number(convertDate(formData.dateTwo));
    // let dateStart = await instanceOne.TIME_START();
    // console.log("Time start is: ", dateStart);
    // dateStart = Number(dateStart);
    // dates1 = Math.round((dates1 - dateStart) / 86400) + 1;
    // dates2 = Math.round((dates2 - dateStart) / 86400) + 1;
    console.log("Works till here");
    try {
      console.log("some details: ", currentAccount,id, dates1, dates2);
      await instanceOne["lease(address,uint256,uint256,uint256)"](currentAccount, id, dates1, dates2);
    } catch (err) {
      console.log(err.message);
    }
  };

  const transferLease = async (id) => {
    // let dates1 = Number(convertDate(formData.dateOne));
    // let dates2 = Number(convertDate(formData.dateTwo));

    let dates1 = convertDate(formData.dateOne);
    let dates2 = convertDate(formData.dateTwo);

    let dateStart = await instanceOne.TIME_START();
    console.log("Date Start is : ", dateStart);
    // dateStart = Number(dateStart);
    // dates1 = Math.round((dates1 - dateStart) / 86400) + 1;
    // dates2 = Math.round((dates2 - dateStart) / 86400) + 1;
    console.log("will run lease: ", formData.wallet,id, dates1, dates2);
    try {
      await instanceOne["lease(address,uint256,uint256,uint256)"](formData.wallet,id, dates1, dates2);
    } catch (err) {
      console.log(err.message);
    }
  };

    const approve = async (id) => {
    // let dates1 = Number(convertDate(formData.dateOne));
    // let dates2 = Number(convertDate(formData.dateTwo));

    let dates1 = convertDate(formData.dateOne);
    let dates2 = convertDate(formData.dateTwo);

    let dateStart = await instanceOne.TIME_START();
    console.log("Date Start is : ", dateStart);
    // dateStart = Number(dateStart);
    // dates1 = Math.round((dates1 - dateStart) / 86400) + 1;
    // dates2 = Math.round((dates2 - dateStart) / 86400) + 1;
    console.log("will run lease: ", formData.wallet,id, dates1, dates2);
    try {
      await instanceOne.approveLease(formData.wallet,id, dates1, dates2);
    } catch (err) {
      console.log(err.message);
    }
  };

  const unlease = async (id) => {

    console.log("entering unlease");
    // let dates1 = Number(convertDate(formData.dateOne));
    // let dates2 = Number(convertDate(formData.dateTwo));
    let dates1 = convertDate(formData.dateOne);
    let dates2 = convertDate(formData.dateTwo);

    let dateStart = await instanceOne.TIME_START();
    // dateStart = Number(dateStart);
    // dates1 = Math.round((dates1 - dateStart) / 86400) + 1;
    // dates2 = Math.round((dates2 - dateStart) / 86400) + 1;

    try {
      await instanceOne["unlease(uint256,uint256,uint256)"](id, dates1, dates2);
    } catch (err) {
      console.log(err.message);
    }
  };

    const approveforAll = async () => {

    console.log("entering approveforAll");

    try {
      await instanceOne.setLeaseApprovalForAll(formData.wallet, true);
    } catch (err) {
      console.log(err.message);
    }
  };
      const unapproveforAll = async () => {

    console.log("entering unapproveforAll");
    
    try {
      await instanceOne.setLeaseApprovalForAll(formData.wallet, false);
    } catch (err) {
      console.log(err.message);
    }
  };



  const unleaseTwo = async (id, dates1, dates2) => {

    console.log("entering unlease", id, dates1, dates2);
    // let dates1 = Number(convertDate(formData.dateOne));
    // let dates2 = Number(convertDate(formData.dateTwo));

    let dateStart = await instanceOne.TIME_START();
    // dateStart = Number(dateStart);
    // dates1 = Math.round((dates1 - dateStart) / 86400) + 1;
    // dates2 = Math.round((dates2 - dateStart) / 86400) + 1;

    try {
      await instanceOne["unlease(uint256,uint256,uint256)"](id, dates1, dates2);
    } catch (err) {
      console.log(err.message);
    }
  };

console.log(allLeases, " All leases")

  useEffect(() => {
    fetchAccountData();
  }, [fetchAccountData]);

  useEffect(() => {
    getAllAssets();
  }, [instanceOne, currentAccount, getAllAssets]);

  useEffect(() => {
    getAllLeases();
  }, [instanceOne, currentAccount, getAllLeases]);

  return (
    // <ContractsAppContext>
    //   <EthersAppContext>
    <div className="background min-h-screen text-white p-10">
      <div className="text-center content-center tracking-wide w-56 relative widgets shadow-lg sm:rounded-3xl bg-clip-padding shadow-white mx-auto contrast-100 shadow-2xl p-3 rounded-2xl mb-3">
        <h6 className="text-xl wordwrap text-tahiti-900 subpixel-antialiased ">
          Mint Asset
        </h6>

        <ModalMint
          textField={"Mint"}
          currentAccount={currentAccount}
          connect={onConnect}
        ></ModalMint>
      </div>

      <div className="flex items-center justify-center mx-24">
        {allAssets && allLeases.length > 0 ? (
          allAssets.map((token, index) => {
            return (
              <div
                key={index}
                className="bg-white font-semibold text-center rounded-3xl border shadow-lg p-10 max-w-lg m-2 w-96"
              >
                <img
                  className="mb-3 w-48 h-48 rounded-full shadow-lg mx-auto"
                  src={`https://ipfs.io/ipfs/${token.image}`}
                  alt="jet"
                />
                <h1 className="text-lg text-gray-700">{token.name}</h1>
                <p className="text-md text-gray-400 mt-4">
                  {token.description}
                </p>
                <ModalAccess id={token.id} account={currentAccount} date = {formData.dateOne} />
                <div>
                  <label className="mr-2 text-blue-900">Start Date</label>
                  <input
                    id="dateOne"
                    type="date"
                    name="dateOne"
                    placeholder="Start Date"
                    onChange={handleChange}
                    className="w-full h-10 px-3 text-base text-gray-700 placeholder-gray-600 border rounded-lg focus:shadow-outline mb-2"
                    required
                  />
                  <label className="mr-2 text-blue-900">End Date</label>
                  <input
                    id="dateTwo"
                    type="date"
                    name="dateTwo"
                    placeholder="End Date"
                    onChange={handleChange}
                    className="w-full h-10 px-3 text-base text-gray-700 placeholder-gray-600 border rounded-lg focus:shadow-outline mb-2"
                    required
                  />
                  <label className="mr-2 text-blue-900">Wallet Address (lease and approve only)</label>
                  
                  <input
                    id="wallet"
                    type="text"
                    name="wallet"
                    placeholder="Wallet Address"
                    onChange={handleChange}
                    className="inline-block w-full h-10 px-3 text-base text-gray-700 placeholder-gray-600 border rounded-lg focus:shadow-outline mb-2"
                  />

                  <div className="flex justify-center">
                  <button
                    onClick={() => transferLease(token.id)}
                    className="button inline-block"
                  >
                    Lease
                  </button>

                    <button
                      onClick={() => unlease(token.id)}
                      className="button"
                    >
                      Unlease
                    </button>
                    </div>
                    <div className="flex justify-center">
                    <button
                      onClick={() => approve(token.id)}
                      className="button"
                    >
                      Approve
                    </button>
                  
                    <button
                      onClick={() => approveforAll(token.id)}
                      className="button"
                    >
                      Approve for All
                    </button>
                    <button
                      onClick={() => unapproveforAll(token.id)}
                      className="button"
                    >
                      Unapprove for All
                    </button>

                  </div>
                  </div>
                {allLeases[index].filter(lease => Number(lease.startTime)).map((leases, leaseIndex) => {
                  return (
                  <div onClick={async () => {
                    console.log("UnleaseTwo is about to run ", index, leases.startTime, leases.endTime)
                    await unleaseTwo(token.id, Number(leases.startTime), Number(leases.endTime))
                    console.log("UnleaseTwo has run!!!")
                  }} className="text-black mx-auto border-b-4 border-black p-1" key={leaseIndex}>
                  <div className="w-64 truncate">Lessee: {leases.lessee}:</div>
                  Dates: {dateReadable(Number(leases.startTime)*1000)} - {dateReadable(Number(leases.endTime*1000))}
                  </div>
                )
                })}
              </div>
            );
          })
        ) : (
          <div></div>
        )}
      </div>
    </div>
  );
};

export default App;
