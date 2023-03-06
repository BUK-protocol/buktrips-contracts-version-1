<script setup lang="ts">
import { ref, onMounted } from "vue";

const account = ref("");
const request = ref("");
const result = ref("");
const ethereum = window.ethereum as any;
const connect = async () => {
  // cehck if metamask is installed
  if (typeof window.ethereum === "undefined") {
    alert("Please install MetaMask first.");
    return;
  }
  const accounts = await ethereum.request({ method: "eth_requestAccounts" });
  account.value = accounts[0];
};

const sign = async () => {
  await connect();
  const msgParams = JSON.stringify({
    domain: {
      // Defining the chain aka Rinkeby testnet or Ethereum Main Net
      chainId: 80001,
      // Give a user friendly name to the specific contract you are signing for.
      name: 'Ether Mail',
      // If name isn't enough add verifying contract to make sure you are establishing contracts with the proper entity
      verifyingContract: '0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC',
      // Just let's you know the latest version. Definitely make sure the field name is correct.
      version: '1',
    },
    // Defining the message signing data content.
    // message: {
    //   contents: 'Hello, Bob!',
    //   from: {
    //     name: 'Cow',
    //     wallets: [
    //       '0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826',
    //       '0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF',
    //     ],
    //   },
    //   to: [
    //     {
    //       name: 'Bob',
    //       wallets: [
    //         '0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB',
    //         '0xB0BdaBea57B0BDABeA57b0bdABEA57b0BDabEa57',
    //         '0xB0B0b0b0b0b0B000000000000000000000000000',
    //       ],
    //     },
    //   ],
    // },
    message: {
      contents: 'Confirm Property Cancelation',
      refund: '0.1',
      commition: '0.1',
      from : account.value,
    },
    // Refers to the keys of the *types* object below.
    primaryType: 'Mail',
    types: {
      // TODO: Clarify if EIP712Domain refers to the domain the contract is hosted on
      EIP712Domain: [
        { name: 'name', type: 'string' },
        { name: 'version', type: 'string' },
        { name: 'chainId', type: 'uint256' },
        { name: 'verifyingContract', type: 'address' },
      ],
      // Refer to PrimaryType
      Mail: [
        { name: 'contents', type: 'string' },
        { name: 'refund', type: 'string' },
        { name: 'commition', type: 'string' },
        { name: 'from', type: 'string' },
      ],
    },
  });
  const params = [account.value,msgParams];
  const method = "eth_signTypedData_v4";
  try {
    const resultl = await ethereum.request({
      method,
      params,
      from:account.value,
    });
    request.value = JSON.stringify(msgParams);
    console.log("🚀 ~ file: App.vue:97 ~ sign ~ result:", resultl)
    result.value = resultl;
  } catch (error) {
    console.error(error);
  }
};
</script>

<template>
    <h1>Auth Example</h1>
    <div class="x-container">
      <main>
        <div class="grid">
          <div class="operations">
            <button class="btn" @click="connect()">Connect</button>
            <button class="btn" @click="sign()">Request signature</button>
          </div>
          <div class="view-window">
            <h2 class="section-heading">STATUS</h2>
            <div class="pill">
              <span class="sub-heading">Current account: </span>
              <span class="sub-value" id="account">{{ account }}</span>
              <br />
            </div>
            <div class="pill">
              <span class="sub-heading">REQ: </span>
              <span class="sub-value" id="request">{{ request }}</span>
              <br />
            </div>
            <div class="pill">
              <span class="sub-heading">RESULT: </span>
              <span class="sub-value" id="result">{{ result }}</span>
              <br />
            </div>
            <hr />
          </div>
        </div>
      </main>
    </div>
</template>


