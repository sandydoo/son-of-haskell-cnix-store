module CNix where

import Foreign
import Foreign.C

#include "nix_api_util.h"
#include "nix_api_store.h"
-- #include "nix_api_expr.h"
-- #include "nix_api_value.h"
-- #include "nix_api_external.h"

data NixStore
data Context

newtype Store = Store (Ptr NixStore)

foreign import ccall "nix_libstore_init"
  initStore :: IO CInt

foreign import ccall "nix_store_open"
  openStore :: CString -> Ptr (Ptr CString) -> IO Store

foreign import ccall "nix_store_unref"
  unrefStore :: Store -> IO ()

foreign import ccall "nix_store_get_uri"
  getUri :: Ptr Context -> Store -> CString -> CUInt -> IO CInt

foreign import ccall "nix_store_get_version"
  getVersion :: Ptr Context -> Store -> CString -> CUInt -> IO CInt

foreign import ccall "nix_version_get"
  getVersionStatic :: IO CString
