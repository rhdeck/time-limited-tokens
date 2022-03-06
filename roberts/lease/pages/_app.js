import React, {
  useEffect,
  useCallback,
  useState,
  useContext,
  createContext,
  useMemo,
} from "react";
import Head from "next/head";
import "../styles/globals.css";
import Layout from "../components/layout/layout.js";

const context = createContext({});
const { Provider } = context;
const Etherizer = ({ children }) => {
  const [hasEthereum, setHasEthereum] = useState(false);
  const [isConnected, setIsConnected] = useState(false);
  const [isConnecting, setIsConnecting] = useState(false);
  useEffect(() => {
    console.log("Window is ", window);
    if (window && window.ethereum) {
      console.log("I am so happy", window.ethereum);
      setHasEthereum(true);
      // if (window.ethereum.isConnected()) {
      //   console.log(window.ethereum.)
      //   setIsConnected(true);
      // }
    }
  }, []);
  const connect = useCallback(() => {
    (async () => {
      console.log("Running requestaccounts");
      setIsConnecting(true);
      try {
        await window.ethereum.send("eth_requestAccounts");
        setIsConnected(window.ethereum.isConnected());
      } catch (error) {}
      setIsConnecting(false);
    })();
  }, []);

  const value = useMemo(() => {
    return { isConnected };
  }, [isConnected]);
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

function MyApp({ Component, pageProps }) {
  return (
    <Etherizer>
      <Layout>
        <Head>
          <meta
            name="viewport"
            content="initial-scale=1.0, width=device-width"
          />
          <title>LeaseIt: Lease Assests on Web3</title>
          <meta charset="utf-8" />
          <meta name="twitter:card" content="summary" />
          <meta property="og:title" content="LeaseIt: Lease Assets on Web3" />
          <meta
            name="og:description"
            content="Decentralized leasing dApp that allows users to lease assets"
          />
        </Head>
        <Component {...pageProps} />
      </Layout>
    </Etherizer>
  );
}

export default MyApp;
