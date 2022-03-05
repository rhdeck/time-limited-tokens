import React, { useEffect, useState } from "react";
import classes from "./main-header.module.css";
import { Navbar, NavDropdown } from "react-bootstrap";
import "bootstrap/dist/css/bootstrap.min.css";
import Image from 'next/image'
import Link from 'next/link'
import { useRouter } from 'next/router'
import { ethers } from "ethers";

function MainHeader() {
    const [currentAccount, setCurrentAccount] = useState("");
    let accounts = [];
    let addSign;
    let newList = [];

    const getAcct = async () => {
      const { ethereum } = window;

      if (ethereum) {
      try {
      accounts = await ethereum.request({ method: "eth_accounts" });

      const newContract = new ethers.providers.InfuraProvider("homestead")

        addSign = await newContract.lookupAddress(accounts[0]);
        if (addSign == null || !addSign) {
          newList.push(accounts[0]);
        } else {
          newList.push(addSign);
        }
      } catch (err) {
        console.log(err.message)
      }
      setCurrentAccount(newList[0])
    }
    }

if (typeof window !== "undefined") {
    const { ethereum } = window;

    if (ethereum) {
      getAcct()
    }
}
    return (    < >
      <div className="bold backgroundHeader headertext w-screen">
      <Navbar expand="xl">
      <div className="sm:flex justify-start mb-3">
      <Link href="/">
        <a className="text-4xl no-underline px-1 font-Lily headertext hover:text-blue-300 sm:mb-0 mb-2">LeaseIt</a>
      </Link>
      <Link href="/">
        <a className="inline-block text-xl no-underline pl-5 headertext hover:text-blue-300 pt-2">Home</a>
      </Link>
      <Link href="/mylist">
        <a className=" inline-block text-xl no-underline px-3 headertext hover:text-blue-300 pt-2">My Leases</a>
      </Link>
</div>
        <div className="flex">
          {currentAccount ?
        <h6 className="text-lg mt-auto overflow-hidden truncate w-72 headertext">Connected to: {currentAccount}</h6> :
    ""
     }
     </div>
        </Navbar>
        </div>
    </>

    );
  }

export default MainHeader;
