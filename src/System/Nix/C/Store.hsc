module System.Nix.C.Store where

import Foreign
import Foreign.C

import System.Nix.C.Util (Context)

#include "nix_api_store.h"

data NixStore
data NixStorePath

newtype Store = Store (Ptr NixStore)

newtype StorePath = StorePath { unStorePath :: Ptr NixStorePath }

foreign import ccall nix_libstore_init :: IO CInt

foreign import ccall nix_store_open ::
   Ptr Context -> CString -> Ptr (Ptr CString) -> IO Store

foreign import ccall nix_store_unref :: Store -> IO ()

foreign import ccall nix_store_get_uri :: Ptr Context -> Store -> CString -> CUInt -> IO CInt

foreign import ccall nix_store_get_version :: Ptr Context -> Store -> CString -> CUInt -> IO CInt

foreign import ccall nix_store_parse_path :: Ptr Context -> Store -> CString -> IO StorePath

foreign import ccall nix_store_is_valid_path :: Ptr Context -> Store -> StorePath -> IO CBool
