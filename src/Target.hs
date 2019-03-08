module Target( Target(..)
             , FindIn(..)
             , FindType(..)
             , findAllTypes
             , findTarget
             , asItem
             , asMob
             , asLink
             ) where

import Data.List (find)
import Data.Map (elems)

import GameObj
import Item
import Mob
import Link
import Room

data Target = TargetNone
            | TargetItem Item
            | TargetMob Mob
            | TargetLink Link
            | TargetNotFound String
            deriving (Eq)

data FindIn = FindInRoom | FindInActor | FindNowhere

data FindType = FindItem | FindMob | FindLink

findAllTypes = [ FindItem, FindMob, FindLink ]

findTarget :: FindIn -> [FindType] -> String -> Mob -> Room -> [Mob] -> Target
findTarget findIn findTypes keyword actor room roomMobs =
    if keyword == "" then
        TargetNone
    else
        let result = foldl (\ acc findType ->
                                if acc == TargetNone then
                                    findTargetSingleType findIn findType keyword actor room roomMobs
                                else
                                    acc
                            ) TargetNone findTypes
        in if result == TargetNone then (TargetNotFound keyword) else result

findInList :: GameObj a => String -> (a -> Target) -> [a] -> Target
findInList keyword ctor list =
    case find (\obj -> GameObj.matches obj keyword) $ list of
        Just obj -> ctor obj
        Nothing -> TargetNone

findTargetSingleType :: FindIn -> FindType -> String -> Mob -> Room -> [Mob] -> Target
findTargetSingleType findIn findType keyword actor room roomMobs =
    case findIn of
        FindInRoom -> case findType of
            FindItem -> findInList keyword TargetItem $ Room.items room
            FindMob -> findInList keyword TargetMob roomMobs
            FindLink -> findInList keyword TargetLink $ elems $ Room.links room
        FindInActor -> case findType of
            FindItem -> findInList keyword TargetItem $ Mob.items actor
            _ -> TargetNone
        FindNowhere -> TargetNone

asItem :: Target -> Either String Item
asItem target = case target of
    TargetItem item -> Right item
    TargetNone -> Left "No item specified"
    TargetNotFound keyword -> Left $ "Could not find an item for '" ++ keyword ++ ".'"
    _ -> Left "That is not an item"

asMob :: Target -> Either String Mob
asMob target = case target of
    TargetMob mob -> Right mob
    TargetNone -> Left "No creature specified"
    TargetNotFound keyword -> Left $ "Could not find a creature for '" ++ keyword ++ ".'"
    _ -> Left "That is not a creature"

asLink :: Target -> Either String Link
asLink target = case target of
    TargetLink link -> Right link
    TargetNone -> Left "No exit specified"
    TargetNotFound keyword -> Left $ "Could not find a exit for '" ++ keyword ++ ".'"
    _ -> Left "That is not a exit"