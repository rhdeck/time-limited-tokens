import React, {
  useEffect,
  useCallback,
  useState,
  useContext,
  createContext,
  useMemo,
} from "react";
import Web3Modal from "web3modal";
import ethers from "ethers";
const context = createContext({});
const { Provider } = context;
export const useEtherizer = () => {
  const { isConnected } = useContext(context);
  return { isConnected };
};
const Etherizer = ({ children }) => {
  const [hasEthereum, setHasEthereum] = useState(false);
  const [isConnected, setIsConnected] = useState(false);
  const [isConnecting, setIsConnecting] = useState(false);
  const [provider, setProvider] = useState();
  const [signer, getSigner] = useState();
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
            setIsConnected(true);
          }
        }
      }
    })();
  }, []);
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
  const connect = useCallback(() => {
    (async () => {
      console.log("Running requestaccounts");
      setIsConnecting(true);
      try {
        const web3Modal = new Web3Modal({
          network: "mainnet", // optional
          cacheProvider: true, // optional
          providerOptions, // required
        });

        const instance = await web3Modal.connect();
        setProvider(new ethers.providers.Web3Provider(instance));
        setSigner(provider.getSigner());
        // await window.ethereum.send("eth_requestAccounts");
        setIsConnected(window.ethereum.isConnected());
      } catch (error) {}
      setIsConnecting(false);
    })();
  }, []);

  const value = useMemo(() => {
    return { isConnected, provider };
  }, [isConnected, provider, signer]);
  if (!hasEthereum) {
    return "No wallet software detected";
  } else if (!isConnected) {
    return (
      <div
        style={{
          display: "flex",
          width: "100vw",
          height: "100vw",
          justifyContent: "center",
          alignItems: "center",
        }}
      >
        <button onClick={connect} className="button" disabled={isConnecting}>
          {isConnecting ? "Connecting..." : "Connect to Mumbai"}
        </button>
      </div>
    );
  } else {
    return <Provider value={value}>{children}</Provider>;
  }
};
export default Etherizer;
