module System.Nix.C.Store where

import Foreign
import Foreign.C

import System.Nix.C.Util (NixContext)

#include "nix_api_store.h"

data NixStore
data NixStorePath

newtype Store = Store (Ptr NixStore)

newtype StorePath = StorePath { unStorePath :: Ptr NixStorePath }

foreign import ccall nix_libstore_init :: Ptr NixContext -> IO CInt

foreign import ccall nix_init_plugins :: Ptr NixContext -> IO CInt

foreign import ccall nix_store_open
  :: Ptr NixContext
  -> CString
  -> Ptr (Ptr CString)
  -> IO Store

foreign import ccall nix_store_unref :: Store -> IO ()

foreign import ccall nix_store_get_uri
  :: Ptr NixContext
  -> Store
  -> CString
  -> CUInt
  -> IO CInt

foreign import ccall nix_store_parse_path
  :: Ptr NixContext
  -> Store
  -> CString
  -> IO StorePath

foreign import ccall nix_store_path_free :: StorePath -> IO ()

foreign import ccall nix_store_is_valid_path
  :: Ptr NixContext
  -> Store
  -> StorePath
  -> IO CBool

foreign import ccall nix_store_build
  :: Ptr NixContext
  -> Store
  -> StorePath
  -> Ptr ()
  -> FunPtr (Ptr () -> CString -> CString -> IO ())
  -> IO CInt

foreign import ccall nix_store_get_version
  :: Ptr NixContext
  -> Store
  -> CString
  -> CUInt
  -> IO CInt
