import React, {
  useEffect,
  useCallback,
  useState,
  useContext,
  createContext,
  useMemo,
} from "react";
import Web3Modal from "web3modal";
import { ethers } from "ethers";
const context = createContext({});
const { Provider } = context;
export const useEtherizer = () => {
  const stuff = useContext(context);
  return stuff;
};
const providerOptions = {
  injected: {
    display: {
      logo: "data:image/gif;base64,INSERT_BASE64_STRING",
      name: "Injected",
      description: "Connect with the provider in your Browser",
    },
    package: null,
  },
};
const network = "mumbai";
const Etherizer = ({ children }) => {
  const [hasEthereum, setHasEthereum] = useState(false);
  const [isConnected, setIsConnected] = useState(false);
  const [isConnecting, setIsConnecting] = useState(false);
  const [provider, setProvider] = useState();
  const [signer, setSigner] = useState();
  useEffect(() => {
    (async () => {
      console.log("Window is ", window);
      if (window && window.ethereum) {
        console.log("I am so happy", window.ethereum);
        setHasEthereum(true);
        if (window.ethereum.isConnected()) {
          console.log("I is connected");
          const accounts = await ethereum.request({ method: "eth_accounts" });
          if (accounts && accounts.length !== 0) {
            console.log("I have accounts");
            setIsConnected(true);
            const p = new ethers.providers.Web3Provider(window.ethereum);
            console.log("I have a provider", p);
            setProvider(p);
            console.log("I have a provider now", p);
            setSigner(p.getSigner());
          }
        }
      }
    })();
  }, []);

  const connect = useCallback(() => {
    (async () => {
      console.log("Running requestaccounts");
      setIsConnecting(true);
      try {
        const web3Modal = new Web3Modal({
          network: network, // optional
          cacheProvider: true, // optional
          providerOptions, // required
        });

        const instance = await web3Modal.connect();
        console.log("I got connected from the connect call", instance);
        const p = new ethers.providers.Web3Provider(instance);
        setProvider(p);
        console.log("I have a provider now", p);
        setSigner(p.getSigner());
        console.log("I hhave a signer now");
        // await window.ethereum.send("eth_requestAccounts");
        setIsConnected(true);
      } catch (error) {
        console.log("This is not work at all!!!!!", error);
      }
      setIsConnecting(false);
    })();
  }, []);
  const disconnect = useCallback(async () => {
    console.log("Disconnect This does not work");
    // await provider.request({method: "wallet_requestPermissions"})
    // await provider.disconnect();
    // setIsConnected(false);
  }, []);
  const value = useMemo(() => {
    return { isConnected, provider, signer, disconnect, ethers };
  }, [isConnected, provider, signer, disconnect]);
  if (!hasEthereum) {
    return "No wallet software detected";
  } else if (!isConnected) {
    return (
      <div
        style={{
          display: "flex",
          width: "100vw",
          height: "100vh",
          justifyContent: "center",
          alignItems: "center",
          flexDirection: "column",
          backgroundImage: "linear-gradient(to top right, blue, pink)",
        }}
      >
        <div
          style={{
            marginBottom: "50px",
            width: "50vw",
            flexDirection: "column",
            justifyContent: "center",
            alignItems: "center",
          }}
        >
          <h1
            className="font-Lily"
            style={{
              fontSize: "3em",
              textAlign: "center",
              fontWeight: "bolder",
            }}
          >
            Air (Web)3-n-B(lockchain)
          </h1>
        </div>
        <button onClick={connect} className="button" disabled={isConnecting}>
          {isConnecting ? "Connecting..." : "Connect to Mumbai"}
        </button>
        <div
          style={{
            marginTop: "50px",
            width: "50vw",
            flexDirection: "column",
            justifyContent: "center",
            alignItems: "center",
          }}
        >
          <h2
            style={{
              textAlign: "center",
              fontWeight: "bolder",
              fontFamily: "Arial Black",
              bottom: 0,
              position: "static",
            }}
          >
            Demonstration for Time Limited Tokens
          </h2>
          <h3 style={{ textAlign: "center" }}>Release your apes</h3>
        </div>
      </div>
    );
  } else {
    return <Provider value={value}>{children}</Provider>;
  }
};
export default Etherizer;
