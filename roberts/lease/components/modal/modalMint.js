import Modal from "react-bootstrap/Modal";
import Button from "react-bootstrap/Button";
import React, { Component } from "react";
import { useState } from "react";
import { ethers } from "ethers";
import abi from "../../abi/TimeLimitedToken.json";

function ModalMint(props) {
  let loader;
let instance;

  const [loading, setLoading] = useState("");

  const { currentAccount, textField, changeColor, connect } = props;

  if (typeof window !== "undefined") {
  const { ethereum } = window;
  if (ethereum && currentAccount) {
  const provider = new ethers.providers.Web3Provider(ethereum);
  const signer = provider.getSigner();
  const dappAddress = "0x812F5575dB0FD5a1c915e986B3dda139D4Bbd490";
  instance = new ethers.Contract(dappAddress, abi.abi, signer);
}
}

  if (loading) {
    loader = (
      <div className="fixed top-0 right-0 h-screen w-screen z-50 flex justify-center items-center">
        <div className="animate-spin rounded-full h-48 w-48 border-t-4 border-b-8 border-blue-900"></div>
      </div>
    );
  } else {
    loader = "";
  }

  const mintNFT = async (name, description, link) => {
    if (currentAccount) {
      const chainId = await ethereum.request({ method: "eth_chainId" });
      console.log(chainId)
    try {
      let nftTxn = await instance.mintAsset(
        formData.name,
        formData.description,
        formData.linkurl
      )
      await nftTxn.wait().then(() => {
        setLoading(false);
      });
    } catch (err) {
      setLoading(false);
      console.log(err.message);
    }
  } else {
    console.log("Not connected")
  }

}

  const [show, setShow] = useState(false);

  const initialFormData = Object.freeze({
    name: "",
    description: "",
    linkurl: "",
  });

  const [formData, updateFormData] = useState(initialFormData);

  const handleChange = async (e) => {
    updateFormData({
      ...formData,

      [e.target.name]: e.target.value,
    });
  };

  const handleClose = () => {
    setShow(false);
  };

  const handleShow = () => {
    setShow(true);
  };

  return (
    <>
    {changeColor ?
      <button
        onClick={handleShow}
        className="text-lg w-auto bg-blue-800 hover:bg-blue-600 text-blue-100 h-auto py-2 px-4 border-blue-700 hover:border-blue-500 rounded-xl mb-2 my-3 mx-2"
      ><svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 inline-block mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
</svg>
        {textField}
      </button>
      :
      <button
        onClick={handleShow}
        className="button"
      ><svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 inline-block mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
</svg>
        {textField}
      </button>
    }
        {loader}
      <Modal show={show} onHide={handleClose} animation={false}>
        <Modal.Header closeButton>
          <Modal.Title className="underline">Enter NFT Details</Modal.Title>
        </Modal.Header>

        <form
          onSubmit={(event) => {
            event.preventDefault();
            mintNFT(formData.name, formData.description, formData.linkurl);
            handleClose();
          }}
        >
          <Modal.Body>
            <div className="form-group mr-sm-2">
              <label className="mr-2 text-blue-900">Name</label>
              <input
                id="name"
                type="text"
                name="name"
                onChange={handleChange}
                className="w-full h-10 px-3 text-base text-gray-700 placeholder-gray-600 border rounded-lg focus:shadow-outline mb-2"
                required
              />
              <label className="mr-2 text-blue-900">Description</label>
              <textarea
                id="description"
                type="text"
                name="description"
                onChange={handleChange}
                required
                className="w-full h-16 px-3 py-2 text-base text-gray-700 placeholder-gray-600 border rounded-lg focus:shadow-outline"
              ></textarea>
            </div>
            <label className="mr-2 text-blue-900">IPFS CID or URL</label>
            <input
              id="linkurl"
              type="text"
              name="linkurl"
              placeholder="e.g. QmZ5gziL... or https://gateway.pinata.cloud/ipfs/QmZ5gziL..."
              onChange={handleChange}
              className="w-full h-10 px-3 text-base text-gray-700 placeholder-gray-600 border rounded-lg focus:shadow-outline mb-2"
              required
            />
          </Modal.Body>
          <Modal.Footer>
            <button className="bg-gray-500 hover:bg-gray-400 text-white h-auto py-2 px-4 border-gray-700 hover:border-gray-500 rounded-2xl mt-2 sm:my-3" onClick={handleClose}>
              Close
            </button>
            <button  type="submit" className="bg-blue-500 hover:bg-blue-400 text-white h-auto py-2 px-4 border-blue-700 hover:border-blue-500 rounded-2xl mt-2 sm:my-3">
              Mint Asset
            </button>
          </Modal.Footer>
        </form>
      </Modal>
    </>
  );
}

export default ModalMint;
