module ItemDef where

import GameDef
import Data.Set

data ItemDef = ItemDef { defId :: DefId
                       , sDesc :: String
                       , lDesc :: String
                       , keywords :: Set String
                       } deriving (Show, Eq)

instance GameDef ItemDef where
    defId def = ItemDef.defId def
    sDesc def = ItemDef.sDesc def
    lDesc def = ItemDef.lDesc def
    matches def keyword = Data.Set.member keyword $ ItemDef.keywords def