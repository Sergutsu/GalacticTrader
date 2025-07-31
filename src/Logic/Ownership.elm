module Logic.Ownership exposing (Ownership, TransferResult(..), canTransfer, changeOwnership, getOwner, isOwner, newOwnership, transferOwnership)

{-| This module handles ownership of game entities like ships, stations, and other assets.
It provides functionality to manage ownership, transfer assets between owners, and check permissions.
-}

import Types.Ownership as Owner exposing (Owner, Permission, Owner(..))


{-| Represents ownership information for an entity
-}
type alias Ownership =
    { currentOwner : Owner
    , originalOwner : Owner
    , permissions : List Permission
    , transferHistory : List TransferRecord
    }


{-| Record of a single ownership transfer
-}
type alias TransferRecord =
    { from : Owner
    , to : Owner
    , timestamp : Int  -- Unix timestamp
    , reason : String  -- e.g., "purchase", "gift", "capture"
    }


{-| Result of an ownership transfer attempt
-}
type TransferResult
    = TransferSuccess Ownership
    | TransferFailed String


{-| Create a new ownership record
-}
newOwnership : Owner -> List Permission -> Ownership
newOwnership owner perms =
    { currentOwner = owner
    , originalOwner = owner
    , permissions = perms
    , transferHistory = []
    }


{-| Check if an owner can perform an action on an owned item
-}
canTransfer : Owner -> Ownership -> Bool
canTransfer potentialOwner ownership =
    case ( potentialOwner, ownership.currentOwner ) of
        ( Owner.PlayerOwner pid1, Owner.PlayerOwner pid2 ) ->
            pid1 == pid2

        ( Owner.FactionOwner fid1, Owner.FactionOwner fid2 ) ->
            fid1 == fid2

        _ ->
            False


{-| Change ownership of an item
-}
changeOwnership : Owner -> Owner -> String -> Ownership -> Ownership
changeOwnership from to reason ownership =
    let
        newTransfer =
            { from = from
            , to = to
            , timestamp = 0  -- This should be set to the current game time
            , reason = reason
            }
    in
    { ownership
        | currentOwner = to
        , transferHistory = newTransfer :: ownership.transferHistory
    }


{-| Transfer ownership if allowed
-}
transferOwnership : Owner -> Owner -> String -> Ownership -> TransferResult
transferOwnership from to reason ownership =
    if canTransfer from ownership then
        TransferSuccess (changeOwnership from to reason ownership)
    else
        TransferFailed "Transfer not authorized"


{-| Get the current owner of an item
-}
getOwner : Ownership -> Owner
getOwner ownership =
    ownership.currentOwner


{-| Check if an owner is the current owner
-}
isOwner : Owner -> Ownership -> Bool
isOwner owner ownership =
    case ( owner, ownership.currentOwner ) of
        ( Owner.PlayerOwner pid1, Owner.PlayerOwner pid2 ) ->
            pid1 == pid2

        ( Owner.FactionOwner fid1, Owner.FactionOwner fid2 ) ->
            fid1 == fid2

        _ ->
            False
