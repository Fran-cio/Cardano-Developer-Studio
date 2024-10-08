{-# LANGUAGE DataKinds          #-}
{-# LANGUAGE FlexibleInstances  #-}
{-# LANGUAGE NoImplicitPrelude  #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings  #-}
--------------------------------------------------------------------------------2
{- HLINT ignore "Use camelCase"          -}
{- HLINT ignore "Reduce duplication"          -}
--------------------------------------------------------------------------------2

module Main where

import           Control.Monad                     (replicateM)
import           PlutusTx.Prelude                  (Maybe (Just, Nothing), ($),
                                                    (.))
import           Prelude                           (IO, mconcat)

import qualified Ledger.Ada                        as LedgerAda
import qualified Plutus.Model                      as Model
import qualified Plutus.V2.Ledger.Api              as LedgerApiV2
import qualified PlutusTx
import qualified Test.Tasty                        as Tasty
import qualified Test.Tasty.HUnit                  as Tasty

import qualified Helpers.OffChain                  as OffChainHelpers
import qualified Helpers.OffChainEval              as OffChainEval

import           DatumCheckAfterDeadlineValidator  (datumCheckAfterDeadlineValidator)
import           DatumCheckBeforeDeadlineValidator (datumCheckBeforeDeadlineValidator)
import           ParamCheckAfterDeadlineValidator  (paramCheckAfterDeadlineValidator)
import           ParamCheckBeforeDeadlineValidator (paramCheckBeforeDeadlineValidator)

---------------------------------------------------------------------------------------------------
------------------------------------------ TESTING ------------------------------------------------

-- | Main function to run the test cases
--
-- This function sets up test groups for different validators to check their behavior
-- before and after deadlines using both parameters and datums.
main :: IO ()
main = Tasty.defaultMain $ do
    Tasty.testGroup
      "Testing time checks validator"
      [ 
        Tasty.testGroup
        "Testing size and resources"
          [
          
              Tasty.testCase "Test Claim After the deadline using datum; Deadline: 6000; TxDate: 6100; TxValidSize < 16Kb; Mem < 14Mb; Cpu < 10_000M" $
              let
                  deadline = 6000
                  txDate = 6100
                  validator = datumCheckAfterDeadlineValidator
                  ctx = claimingTxWithDatumContext validator deadline txDate

                  getValidator :: LedgerApiV2.Address -> Maybe LedgerApiV2.Validator
                  getValidator _ = Just validator

                  getMintingPolicy :: LedgerApiV2.CurrencySymbol -> Maybe LedgerApiV2.MintingPolicy
                  getMintingPolicy _ = Nothing

                  (eval_log, eval_err, eval_size) = OffChainEval.testContext getValidator getMintingPolicy ctx
              in do
                  eval_log `OffChainEval.assertContainsAnyOf` []
                  OffChainEval.assertBudgetAndSize eval_err eval_size OffChainEval.maxMemory OffChainEval.maxCPU OffChainEval.maxTxSize
              ,
              Tasty.testCase "Test Claim Before the deadline using datum; Deadline: 6000; TxDate: 5900; TxValidSize < 16Kb; Mem < 14Mb; Cpu < 10_000M" $
              let
                  deadline = 6000
                  txDate = 5900
                  validator = datumCheckBeforeDeadlineValidator
                  ctx = claimingTxWithDatumContext validator deadline txDate

                  getValidator :: LedgerApiV2.Address -> Maybe LedgerApiV2.Validator
                  getValidator _ = Just validator

                  getMintingPolicy :: LedgerApiV2.CurrencySymbol -> Maybe LedgerApiV2.MintingPolicy
                  getMintingPolicy _ = Nothing

                  (eval_log, eval_err, eval_size) = OffChainEval.testContext getValidator getMintingPolicy ctx
              in do
                  eval_log `OffChainEval.assertContainsAnyOf` []
                  OffChainEval.assertBudgetAndSize eval_err eval_size OffChainEval.maxMemory OffChainEval.maxCPU OffChainEval.maxTxSize
              ,
              Tasty.testCase "Test Claim After the deadline using parameters; Deadline: 6000; TxDate: 6100; TxValidSize < 16Kb; Mem < 14Mb; Cpu < 10_000M" $
              let
                  deadline = 6000
                  txDate = 6100
                  validator = paramCheckAfterDeadlineValidator deadline
                  ctx = claimingTxWithParamsContext validator txDate

                  getValidator :: LedgerApiV2.Address -> Maybe LedgerApiV2.Validator
                  getValidator _ = Just validator

                  getMintingPolicy :: LedgerApiV2.CurrencySymbol -> Maybe LedgerApiV2.MintingPolicy
                  getMintingPolicy _ = Nothing

                  (eval_log, eval_err, eval_size) = OffChainEval.testContext getValidator getMintingPolicy ctx
              in do
                  eval_log `OffChainEval.assertContainsAnyOf` []
                  OffChainEval.assertBudgetAndSize eval_err eval_size OffChainEval.maxMemory OffChainEval.maxCPU OffChainEval.maxTxSize
              ,
              Tasty.testCase "Test Claim Before the deadline using parameters; Deadline: 6000; TxDate: 5900; TxValidSize < 16Kb; Mem < 14Mb; Cpu < 10_000M" $
              let
                  deadline = 6000
                  txDate = 5900
                  validator = paramCheckBeforeDeadlineValidator deadline
                  ctx = claimingTxWithParamsContext validator txDate

                  getValidator :: LedgerApiV2.Address -> Maybe LedgerApiV2.Validator
                  getValidator _ = Just validator

                  getMintingPolicy :: LedgerApiV2.CurrencySymbol -> Maybe LedgerApiV2.MintingPolicy
                  getMintingPolicy _ = Nothing

                  (eval_log, eval_err, eval_size) = OffChainEval.testContext getValidator getMintingPolicy ctx
              in do
                  eval_log `OffChainEval.assertContainsAnyOf` []
                  OffChainEval.assertBudgetAndSize eval_err eval_size OffChainEval.maxMemory OffChainEval.maxCPU OffChainEval.maxTxSize
          ]
        ,
        Tasty.testGroup
            "Test Claim Before the deadline using parameters"
            [ bad   "Deadline: 6000; TxValidRange (6900, 7100)" $ datumCheckBeforeDeadlineTest 6000 (-100) 100 7000
            , good  "Deadline: 6000; TxValidRange (4900, 5100)" $ datumCheckBeforeDeadlineTest 6000 (-100) 100 5000
            ],
        Tasty.testGroup
            "Test claim after the deadline using parameters"
            [ good  "Deadline: 6000; TxValidRange (6900, 7100)" $ datumCheckAfterDeadlineTest 6000 (-100) 100 7000
            , bad   "Deadline: 6000; TxValidRange (4900, 5100)" $ datumCheckAfterDeadlineTest 6000 (-100) 100 5000
            ],
        Tasty.testGroup
            "Test Claim Before the deadline using datums"
            [ bad   "Deadline: 6000; TxValidRange (6900, 7100)" $ paramCheckBeforeDeadlineTest 6000 (-100) 100 7000
            , good  "Deadline: 6000; TxValidRange (4900, 5100)" $ paramCheckBeforeDeadlineTest  6000 (-100) 100 5000
            ],
        Tasty.testGroup
            "Test claim after the deadline using datums"
            [ good  "Deadline: 6000; TxValidRange (6900, 7100)" $ paramCheckAfterDeadlineTest 6000 (-100) 100 7000
            , bad   "Deadline: 6000; TxValidRange (4900, 5100)" $ paramCheckAfterDeadlineTest 6000 (-100) 100 5000
            ]
        ]
  where
    -- | Marks the test as bad (expected to fail)
    bad msg = good msg . Model.mustFail
    -- | Marks the test as good (expected to pass)
    good = Model.testNoErrors (Model.adaValue 10_000_000_000) Model.defaultBabbage

-- | Sets up two users with some initial balance
setupUsers :: Model.Run [LedgerApiV2.PubKeyHash]
setupUsers = replicateM 2 $ Model.newUser $ Model.ada (Model.Lovelace 1000)

type DatumCheckDateValidatorType = Model.TypedValidator LedgerApiV2.POSIXTime ()
type ParamCheckDateValidatorType = Model.TypedValidator () ()

-- | Creates a validator script for checking after the deadline using datum
datumCheckAfterDeadlineValidatorScript :: DatumCheckDateValidatorType
datumCheckAfterDeadlineValidatorScript = Model.TypedValidator $ Model.toV2 datumCheckAfterDeadlineValidator

-- | Creates a validator script for checking after the deadline using parameters
paramCheckAfterDeadlineValidatorScript :: LedgerApiV2.POSIXTime -> ParamCheckDateValidatorType
paramCheckAfterDeadlineValidatorScript deadline = Model.TypedValidator $ Model.toV2
                                        $ paramCheckAfterDeadlineValidator deadline

-- | Creates a validator script for checking before the deadline using datum
datumCheckBeforeDeadlineValidatorScript :: DatumCheckDateValidatorType
datumCheckBeforeDeadlineValidatorScript = Model.TypedValidator $ Model.toV2 datumCheckBeforeDeadlineValidator

-- | Creates a validator script for checking before the deadline using parameters
paramCheckBeforeDeadlineValidatorScript :: LedgerApiV2.POSIXTime -> ParamCheckDateValidatorType
paramCheckBeforeDeadlineValidatorScript deadline = Model.TypedValidator $ Model.toV2
                                        $ paramCheckBeforeDeadlineValidator deadline

--------------------------------------------------------------------------------

-- | Tests the validator for checking claims after the deadline using parameters
--
-- This function sets up a test for the validator script using parameters to check if it correctly
-- handles claims after the deadline.
paramCheckAfterDeadlineTest :: LedgerApiV2.POSIXTime -> LedgerApiV2.POSIXTime -> LedgerApiV2.POSIXTime -> LedgerApiV2.POSIXTime -> Model.Run ()
paramCheckAfterDeadlineTest deadline curMinT curMaxT wSlot = do
  users <- setupUsers
  let [u1, u2] = users
      paramCheckAfterDeadlineScript = paramCheckAfterDeadlineValidatorScript deadline
  makeParamCheckDate u1 u2 paramCheckAfterDeadlineScript curMinT curMaxT wSlot

-- | Tests the validator for checking claims before the deadline using parameters
--
-- This function sets up a test for the validator script using parameters to check if it correctly
-- handles claims before the deadline.
paramCheckBeforeDeadlineTest :: LedgerApiV2.POSIXTime -> LedgerApiV2.POSIXTime -> LedgerApiV2.POSIXTime -> LedgerApiV2.POSIXTime -> Model.Run ()
paramCheckBeforeDeadlineTest deadline curMinT curMaxT wSlot = do
  users <- setupUsers
  let [u1, u2] = users
      paramCheckBeforeDeadlineScript = paramCheckBeforeDeadlineValidatorScript deadline
  makeParamCheckDate u1 u2 paramCheckBeforeDeadlineScript curMinT curMaxT wSlot

-- | Makes a transaction to test a parameter check date validator
makeParamCheckDate :: LedgerApiV2.PubKeyHash -> LedgerApiV2.PubKeyHash -> ParamCheckDateValidatorType -> LedgerApiV2.POSIXTime -> LedgerApiV2.POSIXTime -> LedgerApiV2.POSIXTime -> Model.Run ()
makeParamCheckDate sigUser receiver paramCheckDateScript curMinT curMaxT wSlot = do
  let val = Model.adaValue 100
  Model.checkBalance (Model.gives sigUser val paramCheckDateScript) $ do
    sp <- Model.spend sigUser val
    Model.submitTx sigUser $ vestingTxWithParams paramCheckDateScript sp val
  Model.waitUntil wSlot
  utxos <- Model.utxoAt paramCheckDateScript
  let [(contractRef, contractOut)] = utxos
  Model.checkBalance (Model.gives paramCheckDateScript (LedgerApiV2.txOutValue contractOut) receiver) $ do
    range <- Model.currentTimeInterval curMinT curMaxT
    tx <- Model.validateIn range $ claimingTxWithParams receiver paramCheckDateScript contractRef (LedgerApiV2.txOutValue contractOut)
    Model.submitTx sigUser tx

-- | Creates a vesting transaction with parameters
vestingTxWithParams :: ParamCheckDateValidatorType -> Model.UserSpend -> LedgerApiV2.Value -> Model.Tx
vestingTxWithParams paramCheckDateScript usp val =
  mconcat
    [ Model.userSpend usp
    , Model.payToScript paramCheckDateScript (Model.HashDatum ()) val
    ]

-- | Creates a claiming transaction with parameters
claimingTxWithParams :: LedgerApiV2.PubKeyHash -> ParamCheckDateValidatorType -> LedgerApiV2.TxOutRef -> LedgerApiV2.Value -> Model.Tx
claimingTxWithParams pkh paramCheckDateScript contractRef vestVal =
  mconcat
    [ Model.spendScript paramCheckDateScript contractRef () ()
    , Model.payToKey pkh vestVal
    ]
--------------------------------------------------------------------------------

-- | Tests the validator for checking claims after the deadline using datum
--
-- This function sets up a test for the validator script using datums to check if it correctly
-- handles claims after the deadline.
datumCheckAfterDeadlineTest :: LedgerApiV2.POSIXTime -> LedgerApiV2.POSIXTime -> LedgerApiV2.POSIXTime -> LedgerApiV2.POSIXTime -> Model.Run ()
datumCheckAfterDeadlineTest deadline curMinT curMaxT wSlot = do
  users <- setupUsers
  let [u1, u2] = users
      datumCheckAfterDeadlineScript = datumCheckAfterDeadlineValidatorScript
  makeDatumCheckDate u1 u2 datumCheckAfterDeadlineScript deadline curMinT curMaxT wSlot

-- | Tests the validator for checking claims before the deadline using datum
--
-- This function sets up a test for the validator script using datums to check if it correctly
-- handles claims before the deadline.
datumCheckBeforeDeadlineTest :: LedgerApiV2.POSIXTime -> LedgerApiV2.POSIXTime -> LedgerApiV2.POSIXTime -> LedgerApiV2.POSIXTime -> Model.Run ()
datumCheckBeforeDeadlineTest deadline curMinT curMaxT wSlot = do
  users <- setupUsers
  let [u1, u2] = users
      datumCheckBeforeDeadlineScript = datumCheckBeforeDeadlineValidatorScript
  makeDatumCheckDate u1 u2 datumCheckBeforeDeadlineScript deadline curMinT curMaxT wSlot

-- | Makes a transaction to test a datum check date validator
makeDatumCheckDate :: LedgerApiV2.PubKeyHash -> LedgerApiV2.PubKeyHash -> DatumCheckDateValidatorType -> LedgerApiV2.POSIXTime -> LedgerApiV2.POSIXTime -> LedgerApiV2.POSIXTime -> LedgerApiV2.POSIXTime -> Model.Run ()
makeDatumCheckDate sigUser receiver datumCheckDateScript deadline curMinT curMaxT wSlot = do
  let val = Model.adaValue 100
  Model.checkBalance (Model.gives sigUser val datumCheckDateScript) $ do
    sp <- Model.spend sigUser val
    Model.submitTx sigUser $ vestingTxWithDatum datumCheckDateScript deadline sp val
  Model.waitUntil wSlot
  utxos <- Model.utxoAt datumCheckDateScript
  let [(contractRef, contractOut)] = utxos
  Model.checkBalance (Model.gives datumCheckDateScript (LedgerApiV2.txOutValue contractOut) receiver) $ do
    range <- Model.currentTimeInterval curMinT curMaxT
    tx <- Model.validateIn range $ claimingTxWithDatum receiver datumCheckDateScript deadline contractRef (LedgerApiV2.txOutValue contractOut)
    Model.submitTx sigUser tx

-- | Creates a vesting transaction with datum
vestingTxWithDatum :: DatumCheckDateValidatorType -> LedgerApiV2.POSIXTime -> Model.UserSpend -> LedgerApiV2.Value -> Model.Tx
vestingTxWithDatum datumCheckDateScript deadline usp val =
  mconcat
    [ Model.userSpend usp
    , Model.payToScript datumCheckDateScript (Model.InlineDatum deadline) val
    ]

-- | Creates a claiming transaction with datum
claimingTxWithDatum :: LedgerApiV2.PubKeyHash -> DatumCheckDateValidatorType -> LedgerApiV2.POSIXTime -> LedgerApiV2.TxOutRef -> LedgerApiV2.Value -> Model.Tx
claimingTxWithDatum pkh datumCheckDateScript deadline contractRef vestVal =
  mconcat
    [ Model.spendScript datumCheckDateScript contractRef () deadline
    , Model.payToKey pkh vestVal
    ]

-----------------------------------------------------------------------------------------

claimingTxWithDatumContext :: LedgerApiV2.Validator -> LedgerApiV2.POSIXTime -> LedgerApiV2.POSIXTime ->  LedgerApiV2.ScriptContext
claimingTxWithDatumContext validator deadline txDate =
  let
    uTxO :: LedgerApiV2.TxOut
    uTxO = LedgerApiV2.TxOut
              (OffChainHelpers.addressValidator $ OffChainHelpers.hashValidator validator)
              (LedgerAda.lovelaceValueOf 100)
              (LedgerApiV2.OutputDatum $ LedgerApiV2.Datum $ PlutusTx.toBuiltinData deadline)
              Nothing
    in
      OffChainEval.mkBaseValidatorContext [] [] 0
        OffChainEval.|> OffChainEval.setInputsAndAddRedeemers [(uTxO,  LedgerApiV2.Redeemer $ PlutusTx.toBuiltinData ())]
        OffChainEval.|> OffChainEval.setValidRange (OffChainEval.createValidRange txDate)

-----------------------------------------------------------------------------------------

claimingTxWithParamsContext :: LedgerApiV2.Validator -> LedgerApiV2.POSIXTime ->  LedgerApiV2.ScriptContext
claimingTxWithParamsContext validator txDate =
  let
    uTxO :: LedgerApiV2.TxOut
    uTxO = LedgerApiV2.TxOut
              (OffChainHelpers.addressValidator $ OffChainHelpers.hashValidator validator)
              (LedgerAda.lovelaceValueOf 100)
              (LedgerApiV2.OutputDatum $ LedgerApiV2.Datum $ PlutusTx.toBuiltinData ())
              Nothing
    in
      OffChainEval.mkBaseValidatorContext [] [] 0
        OffChainEval.|> OffChainEval.setInputsAndAddRedeemers [(uTxO,  LedgerApiV2.Redeemer $ PlutusTx.toBuiltinData ())]
        OffChainEval.|> OffChainEval.setValidRange (OffChainEval.createValidRange txDate)

-----------------------------------------------------------------------------------------