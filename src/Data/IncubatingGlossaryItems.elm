module Data.IncubatingGlossaryItems exposing
    ( IncubatingGlossaryItems
    , fromList, insertTag, insert, update, remove
    , get, tags, tagByIdList, tagIdFromTag, tagFromId, disambiguatedPreferredTerm, disambiguatedPreferredTerms, disambiguatedPreferredTermsByAlternativeTerm, itemIdFromDisambiguatedPreferredTermId, preferredTermFromId, disambiguatedPreferredTermsWhichHaveDefinitions, relatedForWhichItems
    , orderedAlphabetically, orderedByMostMentionedFirst, orderedFocusedOn
    )

{-| The glossary items that make up a glossary.


# Glossary Items

@docs IncubatingGlossaryItems


# Build

@docs fromList, insertTag, insert, update, remove


# Query

@docs get, tags, tagByIdList, tagIdFromTag, tagFromId, disambiguatedPreferredTerm, disambiguatedPreferredTerms, disambiguatedPreferredTermsByAlternativeTerm, itemIdFromDisambiguatedPreferredTermId, preferredTermFromId, disambiguatedPreferredTermsWhichHaveDefinitions, relatedForWhichItems


# Export

@docs orderedAlphabetically, orderedByMostMentionedFirst, orderedFocusedOn

-}

import Data.GlossaryItem exposing (alternativeTerms, disambiguationTag)
import Data.GlossaryItem.Definition as Definition exposing (Definition)
import Data.GlossaryItem.Tag as Tag exposing (Tag)
import Data.GlossaryItem.Term as Term exposing (Term)
import Data.GlossaryItem.TermId as TermId exposing (TermId)
import Data.GlossaryItemForHtml as GlossaryItemForHtml exposing (GlossaryItemForHtml, relatedPreferredTerms)
import Data.GlossaryItemId as GlossaryItemId exposing (GlossaryItemId)
import Data.GlossaryItemIdDict as GlossaryItemIdDict exposing (GlossaryItemIdDict)
import Data.IncubatingGlossaryItem as IncubatingGlossaryItem exposing (IncubatingGlossaryItem, alternativeTerms, lastUpdatedDateAsIso8601, preferredTerm)
import Data.TagId as TagId exposing (TagId)
import Data.TagIdDict as TagIdDict exposing (TagIdDict, nextTagId)
import Dict exposing (Dict)
import DirectedGraph exposing (DirectedGraph)
import Extras.Regex
import Maybe
import Regex
import Set exposing (Set)


{-| A set of glossary items.
-}
type IncubatingGlossaryItems
    = IncubatingGlossaryItems
        { itemById : GlossaryItemIdDict IncubatingGlossaryItem
        , tagById : TagIdDict Tag
        , tagIdByRawTag : Dict String TagId
        , disambiguationTagIdByItemId : GlossaryItemIdDict (Maybe TagId)
        , normalTagIdsByItemId : GlossaryItemIdDict (List TagId)
        , itemIdsByTagId : TagIdDict (List GlossaryItemId)
        , itemIdByDisambiguatedPreferredTermId : Dict String GlossaryItemId
        , relatedItemIdsById : GlossaryItemIdDict (List GlossaryItemId)
        , orderedAlphabetically : List GlossaryItemId
        , orderedByMostMentionedFirst : List GlossaryItemId
        , orderedFocusedOn : Maybe ( GlossaryItemId, ( List GlossaryItemId, List GlossaryItemId ) )
        , nextItemId : GlossaryItemId
        , nextTagId : TagId
        }


orderAlphabetically : List ( GlossaryItemId, GlossaryItemForHtml ) -> List GlossaryItemId
orderAlphabetically =
    List.sortWith
        (\( _, item1 ) ( _, item2 ) ->
            Term.compareAlphabetically
                (GlossaryItemForHtml.disambiguatedPreferredTerm item1)
                (GlossaryItemForHtml.disambiguatedPreferredTerm item2)
        )
        >> List.map Tuple.first


orderByMostMentionedFirst : List ( GlossaryItemId, GlossaryItemForHtml ) -> List GlossaryItemId
orderByMostMentionedFirst indexedGlossaryItemsForHtml =
    let
        -- Maps a term to a score based on whether or not it occurs in glossaryItem.
        -- This is done in a primitive way. A more sophisticated solution could use stemming
        -- or other techniques.
        termScoreInItem : Term -> GlossaryItemForHtml -> Int
        termScoreInItem term glossaryItem =
            let
                termAsWord : Regex.Regex
                termAsWord =
                    ("\\b" ++ Extras.Regex.escapeStringForUseInRegex (Term.raw term) ++ "\\b")
                        |> Regex.fromString
                        |> Maybe.withDefault Regex.never

                score : Int
                score =
                    (glossaryItem |> GlossaryItemForHtml.allTerms |> List.map (Term.raw >> Regex.find termAsWord >> List.length) |> List.sum)
                        + (glossaryItem |> GlossaryItemForHtml.definition |> Maybe.map (Definition.raw >> Regex.find termAsWord >> List.length) |> Maybe.withDefault 0)
                        + (glossaryItem |> GlossaryItemForHtml.relatedPreferredTerms |> List.map Term.raw |> List.map (Regex.find termAsWord >> List.length) |> List.sum)
            in
            if score > 0 then
                1

            else
                0

        -- Maps a term to a score based on how often it occurs in indexedGlossaryItemsForHtml.
        termScore : Term -> GlossaryItemId -> Int
        termScore term exceptId =
            indexedGlossaryItemsForHtml
                |> List.foldl
                    (\( id, glossaryItem ) result ->
                        result
                            + (if id == exceptId then
                                0

                               else
                                termScoreInItem term glossaryItem
                              )
                    )
                    0

        termBodyScores : Dict String Int
        termBodyScores =
            indexedGlossaryItemsForHtml
                |> List.concatMap
                    (\( id, glossaryItem ) ->
                        glossaryItem
                            |> GlossaryItemForHtml.allTerms
                            |> List.map (Tuple.pair id)
                    )
                |> List.foldl
                    (\( glossaryItemId, term ) result ->
                        Dict.insert
                            (Term.raw term)
                            (termScore term glossaryItemId)
                            result
                    )
                    Dict.empty
    in
    indexedGlossaryItemsForHtml
        |> List.sortWith
            (\( _, item1 ) ( _, item2 ) ->
                let
                    itemScore : GlossaryItemForHtml -> Int
                    itemScore =
                        GlossaryItemForHtml.allTerms
                            >> List.map
                                (\term ->
                                    termBodyScores
                                        |> Dict.get (Term.raw term)
                                        |> Maybe.withDefault 0
                                )
                            >> List.sum
                in
                case compare (itemScore item1) (itemScore item2) of
                    LT ->
                        GT

                    EQ ->
                        compare
                            (item1 |> GlossaryItemForHtml.disambiguatedPreferredTerm |> Term.raw |> String.toUpper)
                            (item2 |> GlossaryItemForHtml.disambiguatedPreferredTerm |> Term.raw |> String.toUpper)

                    GT ->
                        LT
            )
        |> List.map Tuple.first


{-| Convert a list of glossary items for/from HTML into a `GlossaryItems`.
-}
fromList : List Tag -> List GlossaryItemForHtml -> IncubatingGlossaryItems
fromList tags_ glossaryItemsForHtml =
    let
        indexedGlossaryItemsForHtml : List ( GlossaryItemId, GlossaryItemForHtml )
        indexedGlossaryItemsForHtml =
            List.indexedMap (GlossaryItemId.create >> Tuple.pair) glossaryItemsForHtml

        itemIdByDisambiguatedPreferredTermId_ : Dict String GlossaryItemId
        itemIdByDisambiguatedPreferredTermId_ =
            indexedGlossaryItemsForHtml
                |> List.foldl
                    (\( itemId, item ) ->
                        Dict.insert
                            (GlossaryItemForHtml.disambiguatedPreferredTerm item
                                |> Term.id
                                |> TermId.toString
                            )
                            itemId
                    )
                    Dict.empty

        tagById0 : TagIdDict Tag
        tagById0 =
            tags_
                |> List.indexedMap (TagId.create >> Tuple.pair)
                |> TagIdDict.fromList

        ( itemById, tagById ) =
            indexedGlossaryItemsForHtml
                |> List.foldl
                    (\( itemId, glossaryItemForHtml ) { itemById_, tagById_, allRawTags, nextTagIdInt } ->
                        let
                            glossaryItem : IncubatingGlossaryItem
                            glossaryItem =
                                IncubatingGlossaryItem.init
                                    (GlossaryItemForHtml.nonDisambiguatedPreferredTerm glossaryItemForHtml)
                                    (GlossaryItemForHtml.alternativeTerms glossaryItemForHtml)
                                    (GlossaryItemForHtml.definition glossaryItemForHtml)
                                    (GlossaryItemForHtml.needsUpdating glossaryItemForHtml)
                                    (GlossaryItemForHtml.lastUpdatedDateAsIso8601 glossaryItemForHtml)

                            itemById1 =
                                GlossaryItemIdDict.insert itemId glossaryItem itemById_

                            updated =
                                glossaryItemForHtml
                                    |> GlossaryItemForHtml.allTags
                                    |> List.foldl
                                        (\tag { tagById1, allRawTags1, nextTagIdInt1 } ->
                                            let
                                                rawTag =
                                                    Tag.raw tag
                                            in
                                            if Set.member rawTag allRawTags1 then
                                                { tagById1 = tagById1
                                                , allRawTags1 = allRawTags1
                                                , nextTagIdInt1 = nextTagIdInt1
                                                }

                                            else
                                                { tagById1 =
                                                    TagIdDict.insert
                                                        (TagId.create nextTagIdInt1)
                                                        tag
                                                        tagById1
                                                , allRawTags1 = Set.insert rawTag allRawTags1
                                                , nextTagIdInt1 = nextTagIdInt1 + 1
                                                }
                                        )
                                        { tagById1 = tagById_
                                        , allRawTags1 = allRawTags
                                        , nextTagIdInt1 = nextTagIdInt
                                        }
                        in
                        { itemById_ = itemById1
                        , tagById_ = updated.tagById1
                        , allRawTags = updated.allRawTags1
                        , nextTagIdInt = updated.nextTagIdInt1
                        }
                    )
                    { itemById_ = GlossaryItemIdDict.empty
                    , tagById_ = tagById0
                    , allRawTags = tagById0 |> TagIdDict.values |> List.map Tag.raw |> Set.fromList
                    , nextTagIdInt = tagById0 |> TagIdDict.nextTagId |> TagId.toInt
                    }
                |> (\{ itemById_, tagById_ } -> ( itemById_, tagById_ ))

        tagIdByRawTag : Dict String TagId
        tagIdByRawTag =
            TagIdDict.foldl
                (\tagId tag ->
                    Dict.insert (Tag.raw tag) tagId
                )
                Dict.empty
                tagById

        ( disambiguationTagIdByItemId, normalTagIdsByItemId ) =
            indexedGlossaryItemsForHtml
                |> List.foldl
                    (\( id, item ) ( disambiguationTagByItemId_, normalTagsByItemId_ ) ->
                        ( GlossaryItemIdDict.insert id
                            (item
                                |> GlossaryItemForHtml.disambiguationTag
                                |> Maybe.andThen
                                    (\disambiguationTag ->
                                        Dict.get (Tag.raw disambiguationTag) tagIdByRawTag
                                    )
                            )
                            disambiguationTagByItemId_
                        , GlossaryItemIdDict.insert id
                            (item
                                |> GlossaryItemForHtml.normalTags
                                |> List.filterMap
                                    (\tag ->
                                        Dict.get (Tag.raw tag) tagIdByRawTag
                                    )
                            )
                            normalTagsByItemId_
                        )
                    )
                    ( GlossaryItemIdDict.empty, GlossaryItemIdDict.empty )

        itemIdsByTagId_ : TagIdDict (List GlossaryItemId)
        itemIdsByTagId_ =
            let
                result0 =
                    disambiguationTagIdByItemId
                        |> GlossaryItemIdDict.foldl
                            (\itemId disambiguationTagId result ->
                                disambiguationTagId
                                    |> Maybe.map
                                        (\disambiguationTagId_ ->
                                            TagIdDict.update disambiguationTagId_
                                                (\itemIds ->
                                                    itemIds
                                                        |> Maybe.map ((::) itemId)
                                                        |> Maybe.withDefault [ itemId ]
                                                        |> Just
                                                )
                                                result
                                        )
                                    |> Maybe.withDefault result
                            )
                            TagIdDict.empty
            in
            normalTagIdsByItemId
                |> GlossaryItemIdDict.foldl
                    (\itemId normalTagIds result ->
                        normalTagIds
                            |> List.foldl
                                (\normalTagId result_ ->
                                    TagIdDict.update normalTagId
                                        (\itemIds ->
                                            itemIds
                                                |> Maybe.map ((::) itemId)
                                                |> Maybe.withDefault [ itemId ]
                                                |> Just
                                        )
                                        result_
                                )
                                result
                    )
                    result0

        relatedItemIdsById : GlossaryItemIdDict (List GlossaryItemId)
        relatedItemIdsById =
            indexedGlossaryItemsForHtml
                |> List.foldl
                    (\( id, item ) ->
                        item
                            |> GlossaryItemForHtml.relatedPreferredTerms
                            |> List.filterMap
                                (\relatedPreferredTerm ->
                                    Dict.get
                                        (relatedPreferredTerm |> Term.id |> TermId.toString)
                                        itemIdByDisambiguatedPreferredTermId_
                                )
                            |> GlossaryItemIdDict.insert id
                    )
                    GlossaryItemIdDict.empty

        orderedAlphabetically_ : List GlossaryItemId
        orderedAlphabetically_ =
            orderAlphabetically indexedGlossaryItemsForHtml

        orderedByMostMentionedFirst_ =
            orderByMostMentionedFirst indexedGlossaryItemsForHtml

        nextItemId : GlossaryItemId
        nextItemId =
            itemById
                |> GlossaryItemIdDict.keys
                |> List.map GlossaryItemId.toInt
                |> List.maximum
                |> Maybe.map ((+) 1)
                |> Maybe.withDefault 0
                |> GlossaryItemId.create

        nextTagId : TagId
        nextTagId =
            tagById
                |> TagIdDict.keys
                |> List.map TagId.toInt
                |> List.maximum
                |> Maybe.map ((+) 1)
                |> Maybe.withDefault 0
                |> TagId.create
    in
    IncubatingGlossaryItems
        { itemById = itemById
        , tagById = tagById
        , tagIdByRawTag = tagIdByRawTag
        , disambiguationTagIdByItemId = disambiguationTagIdByItemId
        , normalTagIdsByItemId = normalTagIdsByItemId
        , itemIdsByTagId = itemIdsByTagId_
        , itemIdByDisambiguatedPreferredTermId = itemIdByDisambiguatedPreferredTermId_
        , relatedItemIdsById = relatedItemIdsById
        , orderedAlphabetically = orderedAlphabetically_
        , orderedByMostMentionedFirst = orderedByMostMentionedFirst_
        , orderedFocusedOn = Nothing
        , nextItemId = nextItemId
        , nextTagId = nextTagId
        }


{-| Insert a tag. Does nothing if the tag already exists.
-}
insertTag : Tag -> IncubatingGlossaryItems -> IncubatingGlossaryItems
insertTag tag glossaryItems =
    case glossaryItems of
        IncubatingGlossaryItems items ->
            let
                rawTag =
                    Tag.raw tag
            in
            if Dict.get rawTag items.tagIdByRawTag == Nothing then
                let
                    tagById_ : TagIdDict Tag
                    tagById_ =
                        items.tagById
                            |> TagIdDict.insert items.nextTagId tag

                    tagIdByRawTag_ : Dict String TagId
                    tagIdByRawTag_ =
                        items.tagIdByRawTag
                            |> Dict.insert rawTag items.nextTagId
                in
                IncubatingGlossaryItems
                    { items
                        | tagById = tagById_
                        , tagIdByRawTag = tagIdByRawTag_
                        , nextTagId = TagId.increment items.nextTagId
                    }

            else
                glossaryItems


{-| Insert an item.
-}
insert : GlossaryItemForHtml -> IncubatingGlossaryItems -> IncubatingGlossaryItems
insert item glossaryItems =
    glossaryItems
        |> orderedAlphabetically Nothing
        |> List.map Tuple.second
        |> (::) item
        |> fromList (tags glossaryItems)


{-| Update an item.
-}
update : GlossaryItemId -> GlossaryItemForHtml -> IncubatingGlossaryItems -> IncubatingGlossaryItems
update itemId item glossaryItems =
    glossaryItems
        |> orderedAlphabetically Nothing
        |> List.map
            (\( itemId_, item_ ) ->
                if itemId_ == itemId then
                    item

                else
                    item_
            )
        |> fromList (tags glossaryItems)


{-| Remove the item associated with an ID. Does nothing if the ID is not found.
-}
remove : GlossaryItemId -> IncubatingGlossaryItems -> IncubatingGlossaryItems
remove itemId glossaryItems =
    glossaryItems
        |> orderedAlphabetically Nothing
        |> List.filterMap
            (\( itemId_, itemForHtml ) ->
                if itemId_ == itemId then
                    Nothing

                else
                    Just itemForHtml
            )
        |> fromList (tags glossaryItems)


{-| Get the item associated with an ID. If the ID is not found, return `Nothing`.
-}
get : GlossaryItemId -> IncubatingGlossaryItems -> Maybe GlossaryItemForHtml
get itemId glossaryItems =
    case glossaryItems of
        IncubatingGlossaryItems items ->
            GlossaryItemIdDict.get itemId items.itemById
                |> Maybe.map
                    (\item ->
                        let
                            preferredTerm : Term
                            preferredTerm =
                                IncubatingGlossaryItem.preferredTerm item

                            alternativeTerms =
                                IncubatingGlossaryItem.alternativeTerms item

                            disambiguationTag =
                                items.disambiguationTagIdByItemId
                                    |> GlossaryItemIdDict.get itemId
                                    |> Maybe.andThen identity
                                    |> Maybe.andThen
                                        (\disambiguationTagId ->
                                            TagIdDict.get disambiguationTagId items.tagById
                                        )

                            normalTags =
                                items.normalTagIdsByItemId
                                    |> GlossaryItemIdDict.get itemId
                                    |> Maybe.map
                                        (List.filterMap
                                            (\normalTagId ->
                                                TagIdDict.get normalTagId items.tagById
                                            )
                                        )
                                    |> Maybe.withDefault []

                            definition : Maybe Definition
                            definition =
                                IncubatingGlossaryItem.definition item

                            relatedPreferredTerms : List Term
                            relatedPreferredTerms =
                                items.relatedItemIdsById
                                    |> GlossaryItemIdDict.get itemId
                                    |> Maybe.map
                                        (\relatedItemIds ->
                                            relatedItemIds
                                                |> List.filterMap
                                                    (\relatedItemId ->
                                                        disambiguatedPreferredTerm relatedItemId glossaryItems
                                                    )
                                        )
                                    |> Maybe.withDefault []

                            needsUpdating =
                                IncubatingGlossaryItem.needsUpdating item

                            lastUpdatedDateAsIso8601 =
                                IncubatingGlossaryItem.lastUpdatedDateAsIso8601 item
                        in
                        GlossaryItemForHtml.create
                            preferredTerm
                            alternativeTerms
                            disambiguationTag
                            normalTags
                            definition
                            relatedPreferredTerms
                            needsUpdating
                            lastUpdatedDateAsIso8601
                    )


{-| The tags for these glossary items. Tags can exist without being used in any items.
-}
tags : IncubatingGlossaryItems -> List Tag
tags glossaryItems =
    case glossaryItems of
        IncubatingGlossaryItems items ->
            TagIdDict.values items.tagById


{-| The tags for these glossary items along with their tag IDs.
-}
tagByIdList : IncubatingGlossaryItems -> List ( TagId, Tag )
tagByIdList glossaryItems =
    case glossaryItems of
        IncubatingGlossaryItems items ->
            TagIdDict.toList items.tagById


{-| Look up a tag ID from its contents.
-}
tagIdFromTag : Tag -> IncubatingGlossaryItems -> Maybe TagId
tagIdFromTag tag glossaryItems =
    case glossaryItems of
        IncubatingGlossaryItems items ->
            Dict.get (Tag.raw tag) items.tagIdByRawTag


{-| Look up a tag from its ID.
-}
tagFromId : TagId -> IncubatingGlossaryItems -> Maybe Tag
tagFromId tagId glossaryItems =
    case glossaryItems of
        IncubatingGlossaryItems items ->
            items.tagById
                |> TagIdDict.get tagId


{-| The disambiguated preferred term for the given item with given ID.
-}
disambiguatedPreferredTerm : GlossaryItemId -> IncubatingGlossaryItems -> Maybe Term
disambiguatedPreferredTerm itemId glossaryItems =
    case glossaryItems of
        IncubatingGlossaryItems items ->
            let
                maybePreferredTerm : Maybe Term
                maybePreferredTerm =
                    items.itemById
                        |> GlossaryItemIdDict.get itemId
                        |> Maybe.map IncubatingGlossaryItem.preferredTerm

                disambiguationTagId : Maybe TagId
                disambiguationTagId =
                    items.disambiguationTagIdByItemId
                        |> GlossaryItemIdDict.get itemId
                        |> Maybe.andThen identity

                disambiguationTag : Maybe Tag
                disambiguationTag =
                    disambiguationTagId
                        |> Maybe.andThen
                            (\disambiguationTagId_ ->
                                items.tagById
                                    |> TagIdDict.get disambiguationTagId_
                            )
            in
            maybePreferredTerm
                |> Maybe.map
                    (\preferredTerm_ ->
                        disambiguationTag
                            |> Maybe.map
                                (\disambiguationTag_ ->
                                    preferredTerm_
                                        |> Term.updateRaw
                                            (\raw0 -> raw0 ++ " (" ++ Tag.raw disambiguationTag_ ++ ")")
                                )
                            |> Maybe.withDefault preferredTerm_
                    )


{-| All the disambiguated preferred terms in these glossary items.
-}
disambiguatedPreferredTerms : Maybe TagId -> IncubatingGlossaryItems -> List Term
disambiguatedPreferredTerms filterByTagId glossaryItems =
    case glossaryItems of
        IncubatingGlossaryItems items ->
            let
                itemIds : List GlossaryItemId
                itemIds =
                    filterByTagId
                        |> Maybe.map
                            (\tagId ->
                                items.itemIdsByTagId
                                    |> TagIdDict.get tagId
                                    |> Maybe.withDefault []
                            )
                        |> Maybe.withDefault (GlossaryItemIdDict.keys items.itemById)
            in
            List.filterMap
                (\itemId -> disambiguatedPreferredTerm itemId glossaryItems)
                itemIds


{-| Look up the ID of the item whose preferred term has the given ID.
-}
itemIdFromDisambiguatedPreferredTermId : TermId -> IncubatingGlossaryItems -> Maybe GlossaryItemId
itemIdFromDisambiguatedPreferredTermId termId glossaryItems =
    case glossaryItems of
        IncubatingGlossaryItems items ->
            items.itemIdByDisambiguatedPreferredTermId
                |> Dict.get (TermId.toString termId)


{-| Look up the preferred term of the item whose preferred term has the given ID.
-}
preferredTermFromId : TermId -> IncubatingGlossaryItems -> Maybe Term
preferredTermFromId termId glossaryItems =
    case glossaryItems of
        IncubatingGlossaryItems items ->
            items.itemIdByDisambiguatedPreferredTermId
                |> Dict.get (TermId.toString termId)
                |> Maybe.andThen
                    (\itemId ->
                        GlossaryItemIdDict.get itemId items.itemById
                            |> Maybe.map IncubatingGlossaryItem.preferredTerm
                    )


{-| All of the preferred terms which have a definition.
-}
disambiguatedPreferredTermsWhichHaveDefinitions : Maybe TagId -> IncubatingGlossaryItems -> List Term
disambiguatedPreferredTermsWhichHaveDefinitions filterByTagId glossaryItems =
    case glossaryItems of
        IncubatingGlossaryItems items ->
            let
                itemIdIntsSet : Set Int
                itemIdIntsSet =
                    filterByTagId
                        |> Maybe.andThen (\tagId -> TagIdDict.get tagId items.itemIdsByTagId)
                        |> Maybe.withDefault (GlossaryItemIdDict.keys items.itemById)
                        |> List.map GlossaryItemId.toInt
                        |> Set.fromList
            in
            items.itemById
                |> GlossaryItemIdDict.toList
                |> List.filterMap
                    (\( itemId, item ) ->
                        if
                            Set.member (GlossaryItemId.toInt itemId) itemIdIntsSet
                                && IncubatingGlossaryItem.definition item
                                /= Nothing
                        then
                            disambiguatedPreferredTerm itemId glossaryItems

                        else
                            Nothing
                    )


{-| The IDs of the items that list this item as a related one.
-}
relatedForWhichItems : GlossaryItemId -> IncubatingGlossaryItems -> List GlossaryItemId
relatedForWhichItems itemId glossaryItems =
    case glossaryItems of
        IncubatingGlossaryItems items ->
            items.relatedItemIdsById
                |> GlossaryItemIdDict.foldl
                    (\otherItemId relatedItemIds result ->
                        if List.any ((==) itemId) relatedItemIds then
                            otherItemId :: result

                        else
                            result
                    )
                    []


{-| A list of pairs assocatiating each alternative term with the disambiguated preferred terms that it appears together with.
-}
disambiguatedPreferredTermsByAlternativeTerm : Maybe TagId -> IncubatingGlossaryItems -> List ( Term, List Term )
disambiguatedPreferredTermsByAlternativeTerm filterByTagId glossaryItems =
    case glossaryItems of
        IncubatingGlossaryItems items ->
            let
                ( alternativeTermByRaw, preferredTermsByRawAlternativeTerm ) =
                    items.itemById
                        |> GlossaryItemIdDict.foldl
                            (\itemId item ( alternativeTermByRaw_, preferredTermsByRawAlternativeTerm_ ) ->
                                let
                                    itemMatchesTag : Bool
                                    itemMatchesTag =
                                        filterByTagId
                                            |> Maybe.map
                                                (\filterByTagId_ ->
                                                    (items.disambiguationTagIdByItemId
                                                        |> GlossaryItemIdDict.get itemId
                                                        |> Maybe.map (\disambiguationTagId -> disambiguationTagId == Just filterByTagId_)
                                                        |> Maybe.withDefault False
                                                    )
                                                        || (items.normalTagIdsByItemId
                                                                |> GlossaryItemIdDict.get itemId
                                                                |> Maybe.map (List.member filterByTagId_)
                                                                |> Maybe.withDefault False
                                                           )
                                                )
                                            |> Maybe.withDefault True
                                in
                                if itemMatchesTag then
                                    case disambiguatedPreferredTerm itemId glossaryItems of
                                        Just disambiguatedPreferredTerm_ ->
                                            item
                                                |> IncubatingGlossaryItem.alternativeTerms
                                                |> List.foldl
                                                    (\alternativeTerm ( alternativeTermByRaw1, preferredTermsByRawAlternativeTerm1 ) ->
                                                        let
                                                            raw =
                                                                Term.raw alternativeTerm
                                                        in
                                                        ( Dict.insert raw alternativeTerm alternativeTermByRaw1
                                                        , Dict.update raw
                                                            (\preferredTerms_ ->
                                                                preferredTerms_
                                                                    |> Maybe.map ((::) disambiguatedPreferredTerm_)
                                                                    |> Maybe.withDefault [ disambiguatedPreferredTerm_ ]
                                                                    |> Just
                                                            )
                                                            preferredTermsByRawAlternativeTerm1
                                                        )
                                                    )
                                                    ( alternativeTermByRaw_, preferredTermsByRawAlternativeTerm_ )

                                        Nothing ->
                                            ( alternativeTermByRaw_, preferredTermsByRawAlternativeTerm_ )

                                else
                                    ( alternativeTermByRaw_, preferredTermsByRawAlternativeTerm_ )
                            )
                            ( Dict.empty, Dict.empty )
            in
            preferredTermsByRawAlternativeTerm
                |> Dict.foldl
                    (\rawAlternativeTerm preferredTerms_ result ->
                        Dict.get rawAlternativeTerm alternativeTermByRaw
                            |> Maybe.map (\alternativeTerm -> ( alternativeTerm, preferredTerms_ ) :: result)
                            |> Maybe.withDefault result
                    )
                    []


toList : Maybe TagId -> IncubatingGlossaryItems -> List GlossaryItemId -> List ( GlossaryItemId, GlossaryItemForHtml )
toList filterByTagId glossaryItems =
    case glossaryItems of
        IncubatingGlossaryItems items ->
            let
                itemIdsMatchingTagFilter : Maybe (Set Int)
                itemIdsMatchingTagFilter =
                    filterByTagId
                        |> Maybe.map
                            (\tagId ->
                                items.itemIdsByTagId
                                    |> TagIdDict.get tagId
                                    |> Maybe.map (List.map GlossaryItemId.toInt >> Set.fromList)
                                    |> Maybe.withDefault Set.empty
                            )
            in
            List.filterMap
                (\itemId ->
                    glossaryItems
                        |> get itemId
                        |> Maybe.andThen
                            (\glossaryItemForHtml ->
                                if
                                    itemIdsMatchingTagFilter
                                        |> Maybe.map (Set.member (GlossaryItemId.toInt itemId))
                                        |> Maybe.withDefault True
                                then
                                    Just <| Tuple.pair itemId glossaryItemForHtml

                                else
                                    Nothing
                            )
                )


{-| Retrieve the glossary items ordered alphabetically.
-}
orderedAlphabetically : Maybe TagId -> IncubatingGlossaryItems -> List ( GlossaryItemId, GlossaryItemForHtml )
orderedAlphabetically filterByTagId glossaryItems =
    case glossaryItems of
        IncubatingGlossaryItems items ->
            toList filterByTagId glossaryItems items.orderedAlphabetically


{-| Retrieve the glossary items ordered by most mentioned first.
-}
orderedByMostMentionedFirst : Maybe TagId -> IncubatingGlossaryItems -> List ( GlossaryItemId, GlossaryItemForHtml )
orderedByMostMentionedFirst filterByTagId glossaryItems =
    case glossaryItems of
        IncubatingGlossaryItems items ->
            toList filterByTagId glossaryItems items.orderedByMostMentionedFirst


{-| Retrieve the glossary items ordered "focused on" a specific item.
-}
orderedFocusedOn :
    Maybe TagId
    -> GlossaryItemId
    -> IncubatingGlossaryItems
    ->
        ( List ( GlossaryItemId, GlossaryItemForHtml )
        , List ( GlossaryItemId, GlossaryItemForHtml )
        )
orderedFocusedOn filterByTagId glossaryItemId glossaryItems =
    case glossaryItems of
        IncubatingGlossaryItems items ->
            let
                itemIdsGraph : DirectedGraph GlossaryItemId
                itemIdsGraph =
                    items.itemById
                        |> GlossaryItemIdDict.keys
                        |> List.foldl
                            DirectedGraph.insertVertex
                            (DirectedGraph.empty
                                (GlossaryItemId.toInt >> String.fromInt)
                                (String.toInt >> Maybe.withDefault 0 >> GlossaryItemId.create)
                            )

                relatedItemsGraph : DirectedGraph GlossaryItemId
                relatedItemsGraph =
                    items.relatedItemIdsById
                        |> GlossaryItemIdDict.foldl
                            (\id relatedItemIds result ->
                                let
                                    itemHasDefinition =
                                        items.itemById
                                            |> GlossaryItemIdDict.get id
                                            |> Maybe.map (IncubatingGlossaryItem.definition >> (/=) Nothing)
                                            |> Maybe.withDefault False
                                in
                                if itemHasDefinition then
                                    List.foldl
                                        (DirectedGraph.insertEdge id)
                                        result
                                        relatedItemIds

                                else
                                    result
                            )
                            itemIdsGraph

                ( ids, otherIds ) =
                    DirectedGraph.verticesByDistance glossaryItemId relatedItemsGraph
            in
            ( toList filterByTagId glossaryItems ids
            , toList filterByTagId glossaryItems otherIds
            )