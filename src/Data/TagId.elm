module Data.TagId exposing (TagId, create, toInt, increment)

{-| An identifier for a tag used in a glossary.
These are used to keep track of tags in `GlossaryItems` so that those can be changed safely.

@docs TagId, create, toInt, increment

-}


{-| An opaque type representing the ID of a tag.
-}
type TagId
    = TagId Int


{-| Create a tag ID.
-}
create : Int -> TagId
create =
    TagId


{-| Retrieve the underlying value for a tag ID.
-}
toInt : TagId -> Int
toInt tagId =
    case tagId of
        TagId id ->
            id


{-| Increment the tag ID by one.
-}
increment : TagId -> TagId
increment =
    toInt >> (+) 1 >> create