module Types.Ownership exposing (Owner(..), Permission(..))

{-| This module defines types related to ownership that can be used across the application.
It helps prevent circular dependencies by providing a central place for shared types.
-}


{-| Represents possible owners in the game
-}
type Owner
    = PlayerOwner String  -- Player ID
    | FactionOwner String -- Faction ID
    | NoOwner


{-| Types of permissions that can be granted
-}
type Permission
    = CanSell
    | CanTrade
    | CanModify
    | CanUse
