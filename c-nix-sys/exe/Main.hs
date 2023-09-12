{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Control.Exception
import Foreign.C
import Foreign.Marshal.Alloc (allocaBytes)
import Foreign.Ptr
import qualified System.Nix.C.Store as CNix
import qualified System.Nix.C.Util as CNix

main :: IO ()
main = do
  putStrLn "Nix C API interop"
  putStrLn "Initializing libstore"
  result <- CNix.nix_libstore_init nullPtr
  putStrLn $ "Initialized store. Return code: " ++ show result

  let uri = "daemon"
  putStrLn $ "Opening store: " ++ uri

  bracket (openStore uri) releaseStore tryInteract

tryInteract :: Either String CNix.Store -> IO ()
tryInteract (Left err) = putStrLn err
tryInteract (Right store) = do
  putStrLn "Fetching version"

  clientVersion <- peekCString =<< CNix.nix_version_get
  mdaemonVersion <- getVersion store

  case mdaemonVersion of
    Just daemonVersion ->
      putStrLn $ "Daemon version: " ++ daemonVersion
    Nothing -> putStrLn "Failed to fetch daemon version"

  putStrLn $ "Library version: " ++ clientVersion

  let notInStorePath = "/not/in/store/path"
  checkIfValidPath store notInStorePath

  let invalidPath = "/nix/store/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-stuff"
  checkIfValidPath store invalidPath

  let validPath = "/nix/store/0yy1jjpcimdlw2kp9kd2nmhnpss0zr19-cachix-1.6"
  checkIfValidPath store validPath

checkIfValidPath :: CNix.Store -> String -> IO ()
checkIfValidPath store path = do
  putStrLn $ "Checking store path: " ++ path
  cdata <- CNix.nix_c_context_create
  storePath <- CNix.nix_store_parse_path cdata store =<< newCString path
  if CNix.unStorePath storePath == nullPtr
    then do
      getErrMsg cdata
    else do
      isValid <- CNix.nix_store_is_valid_path cdata store storePath
      putStrLn $ path ++ " is " ++ if isValid == 1 then "valid" else "invalid"

  CNix.nix_c_context_free cdata

getVersion :: CNix.Store -> IO (Maybe String)
getVersion store = do
  let bufferSize = 1024
  allocaBytes bufferSize $ \ptr -> do
    result <- CNix.nix_store_get_version nullPtr store ptr (fromIntegral bufferSize)

    if result == 0
      then Just <$> peekCString ptr
      else return Nothing

openStore :: String -> IO (Either String CNix.Store)
openStore uri = do
  curi <- newCString uri
  cdata <- CNix.nix_c_context_create
  mstore <- CNix.nix_store_open cdata curi nullPtr

  code <- CNix.nix_err_code cdata
  putStrLn $ "Error code: " ++ show code

  if code /= 0
    then do
      getErrMsg cdata
      CNix.nix_c_context_free cdata
      return (Left "Failed to open store")
    else do
      CNix.nix_c_context_free cdata
      return (Right mstore)

releaseStore :: Either String CNix.Store -> IO ()
releaseStore (Left _) = return ()
releaseStore (Right store) = CNix.nix_store_unref store

getErrMsg :: Ptr CNix.NixContext -> IO ()
getErrMsg cdata = do
  let bufferSize = 1024
  allocaBytes bufferSize $ \ptr -> do
    _ <- CNix.nix_err_name nullPtr cdata ptr (fromIntegral bufferSize)
    errMsg <- peekCString =<< CNix.nix_err_msg nullPtr cdata nullPtr
    errName <- peekCString ptr
    putStrLn $ errName ++ ": " ++ errMsg
