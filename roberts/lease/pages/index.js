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
  const thisContract = "0xB6ba57688B4f1c66052AdF245d89A928ccAb988b";
  const instance = new ethers.Contract(thisContract, thisABI.abi, provider);
  const [currentAccount, setCurrentAccount] = useState();
  const [loading, setLoading] = useState(false);
  const [instanceOne, setInstanceOne] = useState(instance);
  const [allAssets, setAllAssets] = useState();

  const convertDate = (date) => {
    const myDate = new Date(date);
    const myEpoch = myDate.getTime() / 1000.0;
    return myEpoch;
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
          console.log("Instance is :",instanceOne);
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

  const lease = async (id) => {
    let dates1 = Number(convertDate(formData.dateOne));
    let dates2 = Number(convertDate(formData.dateTwo));
    let dateStart = await instanceOne.TIME_START;
    dateStart = Number(dateStart);
    dates1 = Math.round((dates1 - dateStart) / 86400) + 1;
    dates2 = Math.round((dates2 - dateStart) / 86400) + 1;

    try {
      await instanceOne.lease(currentAccount, id, dates1, dates2);
    } catch (err) {
      console.log(err.message);
    }
  };

  const transferLease = async (id) => {
    let dates1 = Number(convertDate(formData.dateOne));
    let dates2 = Number(convertDate(formData.dateTwo));

    let dateStart = await instanceOne.TIME_START;
    console.log("Date Start is : ", dateStart);
    dateStart = Number(dateStart);
    dates1 = Math.round((dates1 - dateStart) / 86400) + 1;
    dates2 = Math.round((dates2 - dateStart) / 86400) + 1;

    try {
      await instanceOne.transferLease(id, dates1, dates2, formData.wallet);
    } catch (err) {
      console.log(err.message);
    }
  };

  const unlease = async (id) => {

    console.log("entering unlease");
    let dates1 = Number(convertDate(formData.dateOne));
    let dates2 = Number(convertDate(formData.dateTwo));
    let dateStart = await instanceOne.TIME_START;
    dateStart = Number(dateStart);
    dates1 = Math.round((dates1 - dateStart) / 86400) + 1;
    dates2 = Math.round((dates2 - dateStart) / 86400) + 1;

    try {
      await instanceOne.unlease(id, dates1, dates2);
    } catch (err) {
      console.log(err.message);
    }
  };

  useEffect(() => {
    fetchAccountData();
  }, [fetchAccountData]);

  useEffect(() => {
    getAllAssets();
  }, [instanceOne, currentAccount, getAllAssets]);

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
        {allAssets ? (
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
                <ModalAccess id={token.id} account={currentAccount} />
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
                  <div className="flex justify-center">
                    <button onClick={() => lease(token.id)} className="button">
                      Lease
                    </button>
                    <button
                      onClick={() => unlease(token.id)}
                      className="button"
                    >
                      Unlease
                    </button>
                  </div>
                  <button
                    onClick={() => transferLease(token.id)}
                    className="button inline-block"
                  >
                    Transfer Lease To:
                  </button>
                  <input
                    id="wallet"
                    type="text"
                    name="wallet"
                    placeholder="Wallet Address 0x..."
                    onChange={handleChange}
                    className="inline-block w-full h-10 px-3 text-base text-gray-700 placeholder-gray-600 border rounded-lg focus:shadow-outline mb-2"
                  />
                </div>
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
