import Modal from "react-bootstrap/Modal";
import Button from "react-bootstrap/Button";
import React, { Component } from "react";
import { useState } from "react";
import { ethers } from "ethers";
import abi from "../../abi/TimeLimitedToken.json";

function ModalAccess(props) {
  let loader;
let instance;

  const [loading, setLoading] = useState("");

  const {id, account} = props;
  //let access;
  const [access, setAccess] = useState();
  let dateNow = props.date ? Math.floor(new Date(props.date).valueOf()/1000) : Math.round(Date.now() / 1000);
    
  const getAccess = async () => {
    // let dateNow = Math.round(Date.now() / 1000);
    // console.log("Date now is:", dateNow);
    // let dateStart = await instance.TIME_START;
    // dateNow = Number(dateNow);
    // dateStart = Number(dateStart);
    // const check = Math.round((dateNow-dateStart)/86400);
    let lessee;
    try {

      console.log("id is :", id,"check is :",dateNow);
    lessee = await instance.possessorOf(id,dateNow);
    console.log({account});
    console.log("lessee is ", lessee)
    } catch (err) {
      console.log(err.message);
    }

    // if (lessee == account) {
    //   access = true;
    // } else {
    //   access = false;
    // }
    setAccess(lessee.toLowerCase() == account.toLowerCase() ? lessee: false);
  };


    if (typeof window !== "undefined") {
    const { ethereum } = window;
    if (ethereum && account) {
    const provider = new ethers.providers.Web3Provider(ethereum);
    const signer = provider.getSigner();
    const dappAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
    instance = new ethers.Contract(dappAddress, abi.abi, signer);
    getAccess()
  }
  }



  const [show, setShow] = useState(false);

  const handleClose = () => {
    setShow(false);
  };

  const handleShow = () => {
    setShow(true);
  };

  return (
    <>
    <button
      onClick={handleShow}
      className="button"
    >
      Check Access {new Date(dateNow * 1000).toLocaleString()}
    </button>
      <Modal show={show} onHide={handleClose} animation={false}>

        <Modal.Header closeButton>

        </Modal.Header>

          <Modal.Body>
          {access ?
          <h3 className="text-center">Access Granted to {access}!</h3>
          : <h3 className="text-center">Access Denied!</h3>}
          </Modal.Body>
          <Modal.Footer>
            <button className="bg-gray-500 hover:bg-gray-400 text-white h-auto py-2 px-4 border-gray-700 hover:border-gray-500 rounded-2xl mt-2 sm:my-3" onClick={handleClose}>
              Close
            </button>
          </Modal.Footer>
            </Modal>
    </>
  );
}

export default ModalAccess;
