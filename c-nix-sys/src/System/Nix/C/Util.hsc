module System.Nix.C.Util where

import Foreign
import Foreign.C

#include "nix_api_util.h"

data Context

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

foreign import ccall nix_c_context_create :: IO (Ptr Context)

foreign import ccall nix_c_context_free :: Ptr Context -> IO ()

foreign import ccall nix_libutil_init :: Ptr Context -> IO CInt

foreign import ccall nix_setting_get
  :: Ptr Context
  -> CString
  -> CString
  -> CUInt
  -> CInt

foreign import ccall nix_version_get :: IO CString

foreign import ccall nix_err_msg
  :: Ptr Context
  -> Ptr Context
  -> Ptr CUInt
  -> IO CString

foreign import ccall nix_err_info_msg
  :: Ptr Context
  -> Ptr Context
  -> CString
  -> CInt
  -> CInt

foreign import ccall nix_err_name
  :: Ptr Context
  -> Ptr Context
  -> CString
  -> CInt
  -> IO CInt

foreign import ccall nix_err_code :: Ptr Context -> IO CInt

foreign import ccall nix_set_err_msg
  :: Ptr Context
  -> CInt
  -> CString
  -> IO CInt
