import { AppStateContext, checkSignatureScript } from "@/pages/_app";
import {
  findUTxO,
  safeStringToBigInt,
  signAndSubmitTx,
} from "@/utilities/utilities";
import {
  fromText,
  getAddressDetails,
  MintingPolicy,
  PolicyId,
  Unit,
} from "lucid-cardano";
import { Constr, Data } from "lucid-cardano";
import { useContext, useState } from "react";

export default function Stablecoin() {
  const { appState, setAppState } = useContext(AppStateContext);
  const {
    lucid,
    wAddr,
    contractClass,
    contractType,
    UTxOToClaim,
    UnlockUTxORef,
  } = appState;
  const [tokenName, setTokenName] = useState("");
  const [signature, setSignature] = useState("");
  const [amountToMint, setAmountToMint] = useState(10n);
  const [amountToBurn, setAmountToBurn] = useState(10n);
  const [amountToLock, setValueToLock] = useState(15n);
  ///////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////// HELPER FUNCTIONS ///////////////////////////////////////////
  const getPolicyScript = async (): Promise<MintingPolicy | undefined> => {
    if (!lucid) return;

    if (contractClass == "alwaysTrue") {
      return {
        type: "PlutusV2",
        script: "484701000022120011",
      };
    } else if (contractClass == "alwaysFalse") {
      return {
        type: "PlutusV2",
        script: "4746010000222601",
      };
    }
    return undefined;
  };

  const getUTxOToUnlock = async () => {
    if (!lucid || !UnlockUTxORef) {
      return;
    }
    const UTxOToUnlock = await findUTxO(lucid, UnlockUTxORef);
    console.log("Collateral to unlock UTxOs: ", UTxOToUnlock);
    setAppState({
      ...appState,
      UTxOToClaim: UTxOToUnlock,
    });
  };

  ///////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// MINT /////////////////////////////////////////////////////

  const mintSC = async () => {
    console.log("mintSC -> appState: ", appState);
    const tn = fromText(tokenName);
    const policyScript = await getPolicyScript();
    if (!policyScript) {
      console.log("Policy not selected");
      return;
    }
    const policyId: PolicyId = lucid!.utils.mintingPolicyToId(policyScript);
    const unit: Unit = policyId + tn;

    if (!wAddr || !lucid || amountToMint < 0n) return;
    const pkh: string = getAddressDetails(wAddr!).paymentCredential?.hash || "";

    console.log(tokenName, "   ", tn, "  ", unit);

    const tx = await lucid!
      .newTx()
      .mintAssets({ [unit]: amountToMint }, Data.to(new Constr(0, [])))
      .attachMintingPolicy(policyScript)
      .addSignerKey(pkh)
      .complete();

    await signAndSubmitTx(tx);
  };

  ///////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// BURN /////////////////////////////////////////////////////

  const burnSC = async () => {
    console.log("burnSC -> appState: ", appState);
    const tn = fromText(tokenName);
    const policyScript = await getPolicyScript();
    if (!policyScript) {
      console.log("Policy not selected");
      return;
    }

    const policyId: PolicyId = lucid!.utils.mintingPolicyToId(policyScript);
    const unit: Unit = policyId + tn;

    if (!wAddr || !lucid || amountToBurn < 0n) return;
    const pkh: string = getAddressDetails(wAddr!).paymentCredential?.hash || "";

    const tx = await lucid!
      .newTx()
      .mintAssets({ [unit]: -amountToBurn }, Data.to(new Constr(0, [])))
      .attachMintingPolicy(policyScript)
      .addSignerKey(pkh)
      .complete();

    await signAndSubmitTx(tx);
  };

  ///////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// DEPLOY////////////////////////////////////////////////////

  const deployContract = async () => {
    if (!lucid || !wAddr) {
      alert("Please connect account and mint NFT!");
      return;
    }

    const pkh: string = getAddressDetails(wAddr).paymentCredential?.hash || "";
    const needPkh: string = getAddressDetails(signature).paymentCredential?.hash || "";
    const validator = checkSignatureScript;

    if (!validator) {
      alert("Validator class not defined!");
      return;
    }

    const validatorAddress = lucid!.utils.validatorToAddress(validator);

    const tx = await lucid!
      .newTx()
      .payToContract(
        validatorAddress,
        { inline: Data.to(needPkh, Data.Bytes) },
        { lovelace: amountToLock * 1000000n },
      )
      .addSignerKey(pkh)
      .complete();

    await signAndSubmitTx(tx);
  };

  ///////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// CLAIM ////////////////////////////////////////////////////

  const claimContract = async () => {
    if (!lucid || !wAddr || !UTxOToClaim) {
      alert("Please connect account and mint NFT!");
      return;
    }

    const pkh: string = getAddressDetails(wAddr).paymentCredential?.hash || "";
    const validator = checkSignatureScript;

    if (!validator) {
      alert("Validator class not defined!");
      return;
    }

    const tx = await lucid
      .newTx()
      .collectFrom([UTxOToClaim], Data.to(new Constr(0, [])))
      .attachSpendingValidator(validator)
      .addSignerKey(pkh)
      .complete();

    await signAndSubmitTx(tx);
  };
  ///////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////// UI /////////////////////////////////////////////////

  return (
    <div className="text-zinc-800 font-quicksand">
      {contractType == "validator" && (
        <div className="shadow-[0_4px_0px_0px_rgba(0,0,0,0.25)] w-[664px] bg-zinc-50 border border-zinc-600 rounded-xl p-9">
          <div className="w-full flex flex-row gap-4 mt-2">
          <p>Amount to lock (in ADA):</p>
          <input
            className="w-16 py-1 px-2 ml-3 border border-zinc-700 rounded"
            type="number"
            value={Number(amountToLock)}
            onChange={(e) => {
              const coll = safeStringToBigInt(e.target.value);
              if (!coll) return;
              setValueToLock(coll);
            }}
          />
          </div>
          <div className="w-full flex flex-row gap-4 mt-2">
          <p>Needed signature: (addr format)</p>
          <input
            className="py-1 px-2 ml-3 border border-zinc-700 rounded"
            type="string"
            // value={deadline}
            onChange={(e) => {
              // console.log(e);
              if (!e) return;
              setSignature(String(e.target.value));
            }}
          />
          </div>
          <div className="w-full flex flex-row justify-center gap-4 mt-2">
          <button
            onClick={deployContract}
            disabled={!lucid || !wAddr || !amountToLock}
            className="w-full rounded-lg p-3 text-zinc-50 bg-zinc-800 shadow-[0_5px_0px_0px_rgba(0,0,0,0.6)] disabled:active:translate-y-0 disabled:active:shadow-[0_5px_0px_0px_rgba(0,0,0,0.2)] disabled:bg-zinc-200  disabled:shadow-[0_5px_0px_0px_rgba(0,0,0,0.2)] disabled:text-zinc-600 font-quicksand font-bold active:translate-y-[2px] active:shadow-[0_4px_0px_0px_rgba(0,0,0,0.6)]"
          >
            {" "}
            Deploy Contract
          </button>
          </div>
          <div className="w-full flex flex-row gap-4 mt-2">
            <p>UTxO Ref to unlock:</p>

            <div className="flex flex-col mb-2">
              <input
                className="py-1 px-2 border border-zinc-700 rounded"
                type="string"
                value={UnlockUTxORef || ""}
                onChange={(e) =>
                  setAppState({
                    ...appState,
                    UnlockUTxORef: e.target.value,
                    UTxOToClaim: undefined,
                  })
                }
              />
              <div className="w-full flex flex-row gap-4 mt-2">
                <button
                  onClick={getUTxOToUnlock}
                  disabled={!lucid || !wAddr || !UnlockUTxORef}
                  className="w-full rounded-lg p-3 text-zinc-50 bg-zinc-800 shadow-[0_5px_0px_0px_rgba(0,0,0,0.6)] disabled:active:translate-y-0 disabled:active:shadow-[0_5px_0px_0px_rgba(0,0,0,0.2)] disabled:bg-zinc-200  disabled:shadow-[0_5px_0px_0px_rgba(0,0,0,0.2)] disabled:text-zinc-600 font-quicksand font-bold active:translate-y-[2px] active:shadow-[0_4px_0px_0px_rgba(0,0,0,0.6)]"
                >
                  {" "}
                  Get UTxO to unlock
                </button>

                <button
                  onClick={claimContract}
                  disabled={!lucid || !wAddr || !UTxOToClaim}
                  className="w-full rounded-lg p-3 text-zinc-50 bg-zinc-800 shadow-[0_5px_0px_0px_rgba(0,0,0,0.6)] disabled:active:translate-y-0 disabled:active:shadow-[0_5px_0px_0px_rgba(0,0,0,0.2)] disabled:bg-zinc-200  disabled:shadow-[0_5px_0px_0px_rgba(0,0,0,0.2)] disabled:text-zinc-600 font-quicksand font-bold active:translate-y-[2px] active:shadow-[0_4px_0px_0px_rgba(0,0,0,0.6)]"
                >
                  {" "}
                  Claim Contract
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
      {contractType == "policy" && (
        <div className="shadow-[0_4px_0px_0px_rgba(0,0,0,0.25)] w-[664px] bg-zinc-50 border border-zinc-600 rounded-xl p-9">
          <div className="w-full flex flex-row gap-4 mt-2">
            <p>Token name:</p>
            <input
              className="w-160 py-1 px-2 ml-2 border border-zinc-700 rounded"
              type="string"
              defaultValue={tokenName || ""}
              onChange={(e) => {
                const am = String(e.target.value);
                if (!am) return;
                setTokenName(am);
              }}
            />
          </div>
          <div className="w-full flex flex-row justify-center gap-4 mt-2">
            <p>Tokens to mint (units):</p>
            <input
              className="w-16 py-1 px-2 ml-2 border border-zinc-700 rounded"
              type="number"
              value={Number(amountToMint)}
              onChange={(e) => {
                const am = safeStringToBigInt(e.target.value);
                if (!am) return;
                setAmountToMint(am);
              }}
            />
            <button
              onClick={mintSC}
              disabled={!lucid || !wAddr || !amountToMint || !tokenName}
              className="w-full rounded-lg p-3 text-zinc-50 bg-zinc-800 shadow-[0_5px_0px_0px_rgba(0,0,0,0.6)] disabled:active:translate-y-0 disabled:active:shadow-[0_5px_0px_0px_rgba(0,0,0,0.2)] disabled:bg-zinc-200  disabled:shadow-[0_5px_0px_0px_rgba(0,0,0,0.2)] disabled:text-zinc-600 font-quicksand font-bold active:translate-y-[2px] active:shadow-[0_4px_0px_0px_rgba(0,0,0,0.6)]"
            >
              {" "}
              Mint Tokens
            </button>
          </div>
          <div className="w-full flex flex-row justify-center gap-4 mt-2">
            <p>Tokens to burn (units):</p>
            <input
              className="w-16 py-1 px-2 ml-2 border border-zinc-700 rounded"
              type="number"
              value={Number(amountToBurn)}
              onChange={(e) => {
                const am = safeStringToBigInt(e.target.value);
                if (!am) return;
                setAmountToBurn(am);
              }}
            />
            <button
              onClick={burnSC}
              disabled={!lucid || !wAddr || !amountToBurn || !tokenName}
              className="w-full rounded-lg p-3 text-zinc-50 bg-zinc-800 shadow-[0_5px_0px_0px_rgba(0,0,0,0.6)] disabled:active:translate-y-0 disabled:active:shadow-[0_5px_0px_0px_rgba(0,0,0,0.2)] disabled:bg-zinc-200  disabled:shadow-[0_5px_0px_0px_rgba(0,0,0,0.2)] disabled:text-zinc-600 font-quicksand font-bold active:translate-y-[2px] active:shadow-[0_4px_0px_0px_rgba(0,0,0,0.6)]"
            >
              {" "}
              Burn Tokens
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
