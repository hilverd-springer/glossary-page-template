module Internationalisation.Eng exposing (abbreviation, about, addLinkButton, addRelatedItem, addTagButton, addTermButton, alphabetically, alternativeTerm, ankiDeck, areYouSureYouWantToDeleteThisItem, backToTop, builtUsingGlossaryPageTemplate, builtUsingGlossaryPageTemplateHtmlTree, cancel, cardWidth, cardWidthCompact, cardWidthIntermediate, cardWidthWide, chooseWhichTagShouldBeUsedToDistinguishThisItem, closeSidebar, copyToClipboard, createANewGlossaryItem, createANewGlossaryItemCapitalised, ctrlK, definition, delete, deleteItem, description, disambiguationTag, disambiguationTagOptional, edit, editGlossaryItemCapitalised, editTitleAndAboutSectionButton, editTitleAndAboutSectionHeading, example, explanationForFocusedOn, explanationForMostMentionedFirst, export, failedToParseMarkdown, failedToRenderMarkdown, failedToSave, focusOnTerm, focusedOn, glossaryCapitalised, glossaryContainsTooManyItems, howToEnableMathSupport, howToMakeChangesTitle, httpErrorDescription, links, listTheGroupOfTermsBeingDefined, loadingEllipsis, makeChanges, manageTags, manageTagsTitle, markdownAndTeXSupported, mathSupportIsEnabled, miscellaneous, mostMentionedFirst, moveDown, moveUp, needsUpdating, noMatchingItemsFound, noResultsFound, none, onlyShowingItemsForTag, openOptions, openSidebar, orderItems, otherItems, pleaseSelect, pointToAnyRelatedItems, preferredTerm, preview, provideADefinitionForThisGroupOfTerms, quickSearch, readMore, relatedItem, relatedItems, runTheFollowingCommand, sandboxModeMessage, save, search, searchPlaceholder, see, seeAlso, selectAllTagsThatApplyToThisItem, settings, showExportMenu, showLastUpdatedDates, showOrderItemsButtons, somethingWentWrong, suggestions, tag, tagAppearsMultipleTimes, tags, term, terms, textLabel, themeDark, themeLight, themeSystem, thereAreErrorsOnThisFormSeeAbove, thereAreMultipleItemsWithDisambiguatedPreferredTerm, thereAreMultipleItemsWithTheSameDisambiguatedPreferredTerm, theseSettingsAreUpdatedInTheHtmlFile, title, unableToSaveAsItWouldResultInTheFollowing, updatedOn, url, viewAsSingleItem, webInterfaceDescription, whyTagsMayBeUseful, youCanHideTheseInstructions, youCanUseTagsToAttachLabels)

{-| User interface text in the English language.
-}

import Accessibility.Key
import ElementIds
import Extras.Html
import Extras.HtmlTree as HtmlTree
import Html exposing (Html, a, code, div, p, pre, span, text)
import Html.Attributes exposing (class, href)
import Http


sandboxModeMessage : String
sandboxModeMessage =
    "[Sandbox mode — changes are lost when you reload the page]"


backToTop : String
backToTop =
    "Back to top"


search : String
search =
    "Search"


quickSearch : String
quickSearch =
    "Quick search..."


searchPlaceholder : String
searchPlaceholder =
    "Search..."


noResultsFound : String
noResultsFound =
    "No results found."


export : String
export =
    "Export"


ankiDeck : String
ankiDeck =
    "Anki deck"


themeLight : String
themeLight =
    "Light"


themeDark : String
themeDark =
    "Dark"


themeSystem : String
themeSystem =
    "System"


howToMakeChangesTitle : String
howToMakeChangesTitle =
    "How to Make Changes"


webInterfaceDescription : Html msg
webInterfaceDescription =
    p
        [ class "mt-3" ]
        [ text "This page includes a web interface for making changes that are saved back to the HTML file itself."
        , text " This is meant to be used "
        , span [ class "font-semibold" ] [ text "locally" ]
        , text " by a "
        , span [ class "font-semibold" ] [ text "single user" ]
        , text " at a time and works best if the file is kept under version control."
        ]


runTheFollowingCommand : Bool -> Html msg
runTheFollowingCommand tabbable =
    p []
        [ text "If you're on macOS, Linux, or Cygwin and have "
        , a
            [ href "https://nodejs.org/"
            , Html.Attributes.target "_blank"
            , Accessibility.Key.tabbable tabbable
            ]
            [ text "Node.js" ]
        , text " installed, then run the following command."
        ]


youCanHideTheseInstructions : Html msg
youCanHideTheseInstructions =
    p
        [ class "mt-3 max-w-xl" ]
        [ text "You can hide these instructions altogether by setting the "
        , Extras.Html.inlineCode "data-enable-help-for-making-changes"
        , text " attribute to "
        , Extras.Html.inlineCode "false"
        , text " on the "
        , code [] [ text <| "<div id=\"" ++ ElementIds.container ++ "\">" ]
        , text " element."
        ]


tag : String
tag =
    "Tag"


tags : String
tags =
    "Tags"


onlyShowingItemsForTag : String
onlyShowingItemsForTag =
    "Only showing items for tag:"


orderItems : String
orderItems =
    "Order items"


alphabetically : String
alphabetically =
    "alphabetically"


mostMentionedFirst : String
mostMentionedFirst =
    "most mentioned first"


focusedOn : String
focusedOn =
    "focused on"


pleaseSelect : String
pleaseSelect =
    "Please select"


builtUsingGlossaryPageTemplate : Bool -> Html msg
builtUsingGlossaryPageTemplate tabbable =
    p []
        [ text "Built using "
        , a
            [ Html.Attributes.target "_blank"
            , Accessibility.Key.tabbable tabbable
            , href "https://glossary.page/template"
            ]
            [ span
                [ class "font-semibold print:font-normal" ]
                [ text "Glossary Page Template" ]
            ]
        , span
            [ class "hidden print:inline" ]
            [ text " (https://glossary.page/template)" ]
        , text "."
        ]


builtUsingGlossaryPageTemplateHtmlTree : List HtmlTree.HtmlTree
builtUsingGlossaryPageTemplateHtmlTree =
    [ HtmlTree.Leaf "Built using "
    , HtmlTree.Node "a"
        False
        [ HtmlTree.Attribute "target" "_blank"
        , HtmlTree.Attribute "href" "https://glossary.page/template"
        ]
        [ HtmlTree.Leaf "Glossary Page Template" ]
    , HtmlTree.Leaf "."
    ]


updatedOn : String -> Html msg
updatedOn date =
    div
        [ class "text-right text-sm mt-1.5 mb-2.5 text-gray-500 dark:text-gray-400" ]
        [ text "Updated: "
        , Html.node "last-updated"
            [ Html.Attributes.attribute "datetime" date ]
            []
        ]


makeChanges : String
makeChanges =
    "Make changes"


settings : String
settings =
    "Settings"


seeAlso : String
seeAlso =
    "See also"


see : String
see =
    "See"


explanationForMostMentionedFirst : String
explanationForMostMentionedFirst =
    "Items that are mentioned in many other items are shown first."


explanationForFocusedOn : Html msg -> Html msg
explanationForFocusedOn termHtml =
    p
        [ class "mt-2 text-gray-700 dark:text-gray-300" ]
        [ text "Items closely related to \""
        , termHtml
        , text "\" are shown first. This is determined based on \"See also\" links."
        ]


cardWidth : String
cardWidth =
    "Card width"


cardWidthCompact : String
cardWidthCompact =
    "Compact"


cardWidthIntermediate : String
cardWidthIntermediate =
    "Intermediate"


cardWidthWide : String
cardWidthWide =
    "Wide"


showExportMenu : String
showExportMenu =
    "Show \"Export\" menu"


showOrderItemsButtons : String
showOrderItemsButtons =
    "Show \"Order items\" buttons"


showLastUpdatedDates : String
showLastUpdatedDates =
    "Show last updated date for each item"


editTitleAndAboutSectionButton : String
editTitleAndAboutSectionButton =
    "Edit title and about section"


editTitleAndAboutSectionHeading : String
editTitleAndAboutSectionHeading =
    "Edit Title and About Section"


createANewGlossaryItem : String
createANewGlossaryItem =
    "Create a new glossary item"


manageTags : String
manageTags =
    "Manage tags"


manageTagsTitle : String
manageTagsTitle =
    "Manage Tags"


edit : String
edit =
    "Edit"


delete : String
delete =
    "Delete"


deleteItem : String
deleteItem =
    "Delete item"


areYouSureYouWantToDeleteThisItem : String
areYouSureYouWantToDeleteThisItem =
    "Are you sure you want to delete this item?"


cancel : String
cancel =
    "Cancel"


title : String
title =
    "Title"


about : String
about =
    "About"


addLinkButton : String
addLinkButton =
    "Add link"


url : String
url =
    "URL"


textLabel : String
textLabel =
    "Text"


markdownAndTeXSupported : Bool -> Html msg
markdownAndTeXSupported mathSupportEnabled =
    Html.span
        []
        [ Html.a
            [ Html.Attributes.href "https://commonmark.org/help/"
            , Html.Attributes.target "_blank"
            , class "text-inherit no-underline text-gray-500 dark:text-gray-400 font-normal"
            ]
            [ Html.text "Markdown" ]
        , Extras.Html.showIf mathSupportEnabled <|
            Html.span []
                [ Html.text " and "
                , Html.a
                    [ Html.Attributes.href "https://katex.org/docs/supported.html"
                    , Html.Attributes.target "_blank"
                    , class "text-inherit no-underline text-gray-500 dark:text-gray-400 font-normal"
                    ]
                    [ Html.node "katex-inline"
                        [ Html.Attributes.attribute "data-expr" "\\TeX"
                        ]
                        []
                    ]
                ]
        , Html.text " supported."
        ]


preview : String
preview =
    "Preview"


save : String
save =
    "Save"


thereAreErrorsOnThisFormSeeAbove : String
thereAreErrorsOnThisFormSeeAbove =
    "There are errors on this form — see above."


somethingWentWrong : String
somethingWentWrong =
    "Something went wrong."


links : String
links =
    "Links"


glossaryContainsTooManyItems : Int -> Html msg
glossaryContainsTooManyItems recommendedMaximumNumberOfItems =
    div
        [ class "mt-4 text-red-600 dark:text-red-400 flex items-center max-w-prose" ]
        [ span
            [ class "font-medium" ]
            [ text "⚠ This glossary contains more than "
            , text <| String.fromInt recommendedMaximumNumberOfItems
            , text " items, which is currently "
            , a
                [ href "https://github.com/hilverd/glossary-page-template#known-limitations" ]
                [ text "not recommended" ]
            , text " for performance reasons."
            ]
        ]


noMatchingItemsFound : String
noMatchingItemsFound =
    "No matching items found."


openSidebar : String
openSidebar =
    "Open sidebar"


closeSidebar : String
closeSidebar =
    "Close sidebar"


ctrlK : String
ctrlK =
    "Ctrl K"


theseSettingsAreUpdatedInTheHtmlFile : String
theseSettingsAreUpdatedInTheHtmlFile =
    "These settings are updated in the HTML file when you change them, and the page will reload."


failedToSave : String
failedToSave =
    "Failed to save"


httpErrorDescription : Http.Error -> String
httpErrorDescription error =
    case error of
        Http.BadUrl urlString ->
            "bad URL: " ++ urlString

        Http.Timeout ->
            "the request timed out"

        Http.NetworkError ->
            "there was a network error"

        Http.BadStatus statusCode ->
            "unexpected status code " ++ String.fromInt statusCode

        Http.BadBody body ->
            "unexpected response body: " ++ body


howToEnableMathSupport : Html msg
howToEnableMathSupport =
    div
        [ class "mt-2 max-w-prose" ]
        [ text "To add support for math typesetting, include KaTeX's stylesheet and script inside the "
        , code [] [ text "<head>" ]
        , text " element as shown in the "
        , a
            [ class "font-semibold"
            , href "https://github.com/hilverd/glossary-page-template/releases/latest/download/glossary.html"
            , Html.Attributes.download "glossary.html"
            ]
            [ text "glossary.html" ]
        , text " template."
        ]


mathSupportIsEnabled : Html msg
mathSupportIsEnabled =
    div
        [ class "mt-2 max-w-prose" ]
        [ text "Math typesetting support is enabled. Inline math is written like"
        , pre
            [ class "mt-4" ]
            [ code
                []
                [ text "`$e = mc^2$`" ]
            ]
        , p [ class "mt-4" ] [ text "and display math is written like this:" ]
        , pre
            [ class "mt-4" ]
            [ code
                []
                [ text "```math\ne = mc^2\n```" ]
            ]
        ]


copyToClipboard : String
copyToClipboard =
    "Copy to clipboard"


focusOnTerm : String
focusOnTerm =
    "Focus on term"


glossaryCapitalised : String
glossaryCapitalised =
    "Glossary"


otherItems : String
otherItems =
    "Other items"


description : String
description =
    "Description"


addTagButton : String
addTagButton =
    "Add tag"


unableToSaveAsItWouldResultInTheFollowing : String
unableToSaveAsItWouldResultInTheFollowing =
    "Unable to save as it would result in the following"


thereAreMultipleItemsWithDisambiguatedPreferredTerm : String -> String
thereAreMultipleItemsWithDisambiguatedPreferredTerm rawTerm =
    "there are multiple items with (disambiguated) preferred term \""
        ++ rawTerm
        ++ "\""


thereAreMultipleItemsWithTheSameDisambiguatedPreferredTerm : String
thereAreMultipleItemsWithTheSameDisambiguatedPreferredTerm =
    "there are multiple items with the same (disambiguated) preferred term"


tagAppearsMultipleTimes : String -> String
tagAppearsMultipleTimes rawTag =
    "tag \"" ++ rawTag ++ "\" appears multiple times"


youCanUseTagsToAttachLabels : String
youCanUseTagsToAttachLabels =
    "You can use tags to attach \"labels\" to items that people can then filter by."


readMore : String
readMore =
    "Read more"


whyTagsMayBeUseful : String
whyTagsMayBeUseful =
    "This may be useful for large glossaries that span multiple topics, where there is a need to categorize or group items."
        ++ " Tags can also be used to \"disambiguate\" items that have the same preferred term but whose meaning depends on some \"context\"."
        ++ " For example, the term \"default\" has a different meaning in the context of computer science than it does in the context of finance."


example : String
example =
    "Example"


abbreviation : String
abbreviation =
    "Abbreviation"


terms : String
terms =
    "Terms"


listTheGroupOfTermsBeingDefined : List (Html msg)
listTheGroupOfTermsBeingDefined =
    [ text "List the group of terms being defined. The first one is considered the "
    , Html.em
        []
        [ text "preferred" ]
    , text " term."
    ]


addTermButton : String
addTermButton =
    "Add term"


definition : String
definition =
    "Definition"


provideADefinitionForThisGroupOfTerms : String
provideADefinitionForThisGroupOfTerms =
    "Provide a definition (optional) for this group of terms."


selectAllTagsThatApplyToThisItem : String
selectAllTagsThatApplyToThisItem =
    "Select all tags that apply to this item."


disambiguationTagOptional : String
disambiguationTagOptional =
    "Disambiguation tag (optional)"


disambiguationTag : String
disambiguationTag =
    "Disambiguation tag"


none : String
none =
    "None"


chooseWhichTagShouldBeUsedToDistinguishThisItem : String
chooseWhichTagShouldBeUsedToDistinguishThisItem =
    "If another item has the same preferred term, then choose which tag should be used to distinguish this item."


relatedItem : String
relatedItem =
    "Related item"


moveUp : String
moveUp =
    "Move up"


moveDown : String
moveDown =
    "Move down"


addRelatedItem : String
addRelatedItem =
    "Add related item"


relatedItems : String
relatedItems =
    "Related items"


pointToAnyRelatedItems : String
pointToAnyRelatedItems =
    "Point to any related items the reader might want to look up."


suggestions : String
suggestions =
    "Suggestions"


miscellaneous : String
miscellaneous =
    "Miscellaneous"


needsUpdating : String
needsUpdating =
    "Needs updating"


createANewGlossaryItemCapitalised : String
createANewGlossaryItemCapitalised =
    "Create a New Glossary Item"


editGlossaryItemCapitalised : String
editGlossaryItemCapitalised =
    "Edit Glossary Item"


preferredTerm : String
preferredTerm =
    "Preferred term"


alternativeTerm : String
alternativeTerm =
    "Alternative term"


term : String
term =
    "Term"


openOptions : String
openOptions =
    "Open options"


viewAsSingleItem : String
viewAsSingleItem =
    "View as single item"


loadingEllipsis : String
loadingEllipsis =
    "Loading..."


failedToRenderMarkdown : String
failedToRenderMarkdown =
    "Failed to render Markdown"


failedToParseMarkdown : String
failedToParseMarkdown =
    "Failed to parse Markdown"