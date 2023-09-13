module System.Nix.C.Util where

import Foreign
import Foreign.C

#include "nix_api_util.h"

data NixContext

nix_ok :: CInt
nix_ok = #const NIX_OK

nix_err_unknown :: CInt
nix_err_unknown = #const NIX_ERR_UNKNOWN

nix_err_overflow :: CInt
nix_err_overflow = #const NIX_ERR_OVERFLOW

nix_err_key :: CInt
nix_err_key = #const NIX_ERR_KEY

nix_err_nix_error :: CInt
nix_err_nix_error = #const NIX_ERR_NIX_ERROR

foreign import ccall nix_c_context_create :: IO (Ptr NixContext)

foreign import ccall nix_c_context_free :: Ptr NixContext -> IO ()

foreign import ccall nix_libutil_init :: Ptr NixContext -> IO CInt

foreign import ccall nix_setting_get
  :: Ptr NixContext
  -> CString
  -> CString
  -> CUInt
  -> CInt

foreign import ccall nix_setting_set
  :: Ptr NixContext
  -> CString
  -> CString
  -> CInt

foreign import ccall nix_version_get :: IO CString

foreign import ccall nix_err_msg
  :: Ptr NixContext
  -> Ptr NixContext
  -> Ptr CUInt
  -> IO CString

foreign import ccall nix_err_info_msg
  :: Ptr NixContext
  -> Ptr NixContext
  -> CString
  -> CInt
  -> CInt

foreign import ccall nix_err_name
  :: Ptr NixContext
  -> Ptr NixContext
  -> CString
  -> CInt
  -> IO CInt

foreign import ccall nix_err_code :: Ptr NixContext -> IO CInt

foreign import ccall nix_set_err_msg
  :: Ptr NixContext
  -> CInt
  -> CString
  -> IO CInt
