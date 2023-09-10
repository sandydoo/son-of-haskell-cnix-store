module Main where

import Control.Exception
import Foreign.C
import Foreign.Marshal.Alloc (allocaBytes)
import Foreign.Ptr
import MyLib

main :: IO ()
main = do
  putStrLn "Nix C API interop"
  putStrLn "Initializing libstore"
  result <- initStore
  putStrLn $ "Initialized store. Return code: " ++ show result

  putStrLn "Opening store"

  uri <- newCString "/nix/store"
  bracket (openStore uri nullPtr) unrefStore tryInteract

tryInteract :: Store -> IO ()
tryInteract store = do
  putStrLn "Fetching version"

  clientVersion <- peekCString =<< getVersionStatic
  mdaemonVersion <- getVersion' store

  case mdaemonVersion of
    Just daemonVersion ->
      putStrLn $ "Daemon version: " ++ daemonVersion
    Nothing -> putStrLn "Failed to fetch daemon version"

  putStrLn $ "Library version: " ++ clientVersion

getVersion' :: Store -> IO (Maybe String)
getVersion' store = do
  let bufferSize = 1024
  allocaBytes bufferSize $ \ptr -> do
    result <- getVersion nullPtr store ptr (fromIntegral bufferSize)

    if result == 0
      then Just <$> peekCString ptr
      else return Nothing
