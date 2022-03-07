import React, { useEffect, useState, Fragment } from "react";
import classes from "./main-header.module.css";
import { Navbar, NavDropdown } from "react-bootstrap";
import "bootstrap/dist/css/bootstrap.min.css";
import Link from "next/link";
import { useRouter } from "next/router";
import { ethers } from "ethers";
import { useEtherizer } from "../Etherizer";
function MainHeader() {
  const { disconnect } = useEtherizer();
  console.log("loading mainheader", useEtherizer());
  const [currentAccount, setCurrentAccount] = useState("");
  let accounts = [];
  let addSign;
  let newList = [];

  const getAcct = async () => {
    const { ethereum } = window;

    try {
      accounts = await ethereum.request({ method: "eth_accounts" });

      const newContract = new ethers.providers.InfuraProvider("homestead");

      addSign = await newContract.lookupAddress(accounts[0]);
      if (addSign == null || !addSign) {
        newList.push(accounts[0]);
      } else {
        newList.push(addSign);
      }
    } catch (err) {
      console.log(err.message);
    }
    setCurrentAccount(newList[0]);
  };

  if (typeof window !== "undefined") {
    const { ethereum } = window;

    if (ethereum) {
      getAcct();
    }
  }
  return (
    <>
      <div className="bold backgroundHeader headertext w-screen">
        <Navbar expand="xl">
          <div className="sm:flex justify-between items-center mb-3 w-full">
            <div className="sm:flex justify-start">
              <Link href="/">
                <div>
                  <a className="block text-2xl no-underline px-1 font-Lily headertext hover:text-blue-300 -mb-2">
                    Air3-n-B
                  </a>
                  <div className="italic ml-2">by leaseit</div>
                </div>
              </Link>
              <Link href="/">
                <a className="inline-block text-xl no-underline pl-5 headertext hover:text-blue-300 pt-2">
                  Home
                </a>
              </Link>
              <Link href="/mylist">
                <a className=" inline-block text-xl no-underline px-3 headertext hover:text-blue-300 pt-2">
                  My Leases
                </a>
              </Link>
            </div>
            <div className="align-right inline-block text-xl no-underline px-3 headertext pt-2">
              Wallet: {currentAccount.substring(0, 6)}...
            </div>
          </div>
        </Navbar>
      </div>
    </>
  );
}

export default MainHeader;
