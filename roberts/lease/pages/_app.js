import Head from "next/head";
import "../styles/globals.css";
import Layout from "../components/layout/layout.js";
import Etherizer from "../components/Etherizer";
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
