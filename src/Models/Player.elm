module Models.Player exposing (Player, PlayerId, newPlayer, addAsset, canPerform, grantPermission, hasPermission, removeAsset, revokePermission, toOwner, transferAsset)

{-| This module defines the Player type and related functions.
It's used to represent players in the game and manage their data.
-}

import Types.Ownership as OwnershipTypes exposing (Owner(..), Permission(..))


type alias PlayerId =
    String


type alias Player =
    { id : PlayerId
    , name : String
    , credits : Int
    , factionId : Maybe String
    , ownedAssets : List String  -- List of asset IDs owned by the player
    , permissions : List ( String, Permission )  -- (assetId, permission) pairs
    }


{-| Create a new player with default values
-}
newPlayer : PlayerId -> String -> Int -> Player
newPlayer id name startingCredits =
    { id = id
    , name = name
    , credits = startingCredits
    , factionId = Nothing
    , ownedAssets = []
    , permissions = []
    }


{-| Check if a player has a specific permission on an asset
-}
hasPermission : Player -> String -> Permission -> Bool
hasPermission player assetId permission =
    List.any (\(id, perm) -> id == assetId && perm == permission) player.permissions


{-| Check if a player can perform a specific action on an asset
-}
canPerform : Player -> String -> Permission -> Bool
canPerform player assetId permission =
    List.any (\id -> id == assetId) player.ownedAssets
        && hasPermission player assetId permission


{-| Grant a permission to a player for a specific asset
-}
grantPermission : Player -> String -> Permission -> Player
grantPermission player assetId permission =
    if hasPermission player assetId permission then
        player
    else
        { player | permissions = ( assetId, permission ) :: player.permissions }


{-| Revoke a permission from a player for a specific asset
-}
revokePermission : Player -> String -> Permission -> Player
revokePermission player assetId permission =
    { player
        | permissions =
            List.filter
                (\(id, perm) -> not (id == assetId && perm == permission))
                player.permissions
    }


{-| Add an asset to the player's list of owned assets
-}
addAsset : Player -> String -> Player
addAsset player assetId =
    if List.member assetId player.ownedAssets then
        player
    else
        { player | ownedAssets = assetId :: player.ownedAssets }


{-| Remove an asset from the player's list of owned assets
-}
removeAsset : Player -> String -> Player
removeAsset player assetId =
    { player
        | ownedAssets = List.filter (\id -> id /= assetId) player.ownedAssets
        , permissions = List.filter (\(id, _) -> id /= assetId) player.permissions
    }


{-| Transfer an asset from one player to another
-}
transferAsset : Player -> Player -> String -> ( Player, Player )
transferAsset fromPlayer toPlayer assetId =
    let
        -- Remove asset and permissions from the original owner
        updatedFrom =
            removeAsset fromPlayer assetId

        -- Add asset to the new owner and copy relevant permissions
        updatedTo =
            toPlayer
                |> addAssetHelper assetId
                |> (\p ->
                        List.foldl
                            (\(id, perm) acc ->
                                if id == assetId then
                                    grantPermission acc id perm
                                else
                                    acc
                            )
                            p
                            fromPlayer.permissions
                   )
    in
    ( updatedFrom, updatedTo )


{-| Helper function to add an asset to a player
This is needed because we can't use the pipe operator with multiple arguments
-}
addAssetHelper : String -> Player -> Player
addAssetHelper assetId player =
    addAsset player assetId


{-| Convert a player to an Owner type
-}
toOwner : Player -> Owner
toOwner player =
    OwnershipTypes.PlayerOwner player.id