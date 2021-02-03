module Global ( InternalError(..) ) where

import Control.Exception ( Exception)
import Type.Reflection ( Typeable )

newtype InternalError = Error String 
    deriving (Show, Typeable)

instance Exception InternalError
