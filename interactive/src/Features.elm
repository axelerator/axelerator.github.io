module Features exposing (Model, Msg, init, update, view)

import Color exposing (Color)
import Csv.Decode as Csv
import Curve
import Hierarchy
import Html exposing (Html)
import List.Extra
import Path exposing (Path)
import Scale exposing (OrdinalScale)
import Scale.Color
import Set
import Shape
import Svg.Lazy
import Tree exposing (Step(..), Tree)
import TypedSvg exposing (g, rect, svg, text_)
import TypedSvg.Attributes exposing (dy, fill, stroke, textAnchor, transform, viewBox)
import TypedSvg.Attributes.InPx exposing (height, rx, strokeWidth, width, x, y)
import TypedSvg.Core exposing (Svg, text)
import TypedSvg.Events
import TypedSvg.Types exposing (AnchorAlignment(..), Opacity(..), Paint(..), Transform(..), em)
import TypedSvg exposing (textPath)
import TypedSvg.Attributes exposing (href)
import TypedSvg.Attributes exposing (startOffset)
import TypedSvg.Attributes exposing (alignmentBaseline)
import TypedSvg.Types exposing (AlignmentBaseline(..))
import TypedSvg.Attributes exposing (dx)
import TypedSvg.Types exposing (Length(..))
import TypedSvg.Attributes exposing (class)
import TypedSvg.Core exposing (foreignObject)
import TypedSvg.Core exposing (node)
import TypedSvg.Attributes exposing (xmlSpace)
import TypedSvg.Attributes exposing (requiredExtensions)
import TypedSvg.Core exposing (attribute)
import TypedSvg exposing (tspan)
import Html exposing (figure)

-- storage - upload
-- storage - email
-- retrieval - parse pdf
-- retrieval - parse image

featuresStr ="""retrieval-tags,3
retrieval-sender,3
retrieval-search,3
productivity-tasks-workflows,6
access-privacy-sbc,3
access-mobile-native,3
access-backup-cloud,3
access-backup-usb,3"""


{-| We can use Hierarchy to visualize data that is not naturally in a tree like format.
In this example the data is a list of sequences of page visits users have made on
a website and looks like this:

    account-account-account-account-account-account,22781
    account-account-account-account-account-end,3311
    account-account-account-account-account-home,906
    ...

We turn this into a tree-like data structure by making the parent of each item
its prefix (so the parent of `account-account-account-account-account-home` is
`account-account-account-account-account`), then aggregating the counts up the
tree.

To make this visualization performant and sensible, the sequences are limited
in the dataset to be six or less and the long tail of pages is aggregated into
an `other` category. We distinguish truncated and complete sequences by adding
the `end` token to a complete sequence (the `end` can be understood as the user
leaving the website).

For serious deployment, a server could provide additional data combined with
zooming in on subsets interactively.

Based on work by Kerry Roden (under Apache 2 License).

@requires data/visit-sequences.csv
@category Advanced
@delay 1

-}



-- Constants


w : Float
w =
    500


h : Float
h =
    500


radius : Float
radius =
    min w h / 2


spacing : Float
spacing =
    50




-- Types


type alias Datum =
    { sequence : List String, category : String, visits : Int }


type alias Data =
    Tree Datum


type alias LayedOutDatum =
    { x : Float, y : Float, width : Float, height : Float, value : Float, node : Datum }


type alias LoadedModel =
    { layout : List LayedOutDatum
    , categories : List String
    , hovered : Maybe { sequence : List String, percentage : Float }
    , total : Float
    , colorScale : OrdinalScale String Color
    }


type Model
    = Loading
    | Loaded LoadedModel


type Msg
    = Hover (Maybe { sequence : List String, percentage : Float })

type alias FeatureDescription =
  { title: String
  , body: String
  }

featureDescription : List String -> FeatureDescription
featureDescription sequence =
  case sequence of
    ["retrieval"] ->
      { title = "Document retrieval"
      , body = "Features that help the user to find and open uploaded documents efficiently"
      }
    ["retrieval", "tags"] ->
      { title = "Tagging"
      , body = "Allow users to add tags to documents and enable search by tags"
      }
    ["retrieval", "sender"] ->
      { title = "Sender detection"
      , body = "Senders in documents get autodected or can be added by hand to new documents. Documents can be listed and searched by sender."
      }
    ["retrieval", "search"] ->
      { title = "Fulltext search"
      , body = "A search for a word will bring up a list of all documents containing that word."
      }
    ["productivity"] ->
      { title = "Productivity"
      , body = "Features that help users with follow up work that involves a document after it has been uploaded"
      }
    ["productivity", "tasks"] ->
      { title = "Tasks"
      , body = "Recording follow up tasks and due dates for a particular document"
      }
    ["productivity", "tasks", "workflows"] ->
      { title = "Automated workflows"
      , body = "Define recurring chains of tasks. E.g. (Medical invoice -> Claim -> Verify claimed amount arrived )"
      }
    ["access"] ->
      { title = "Access"
      , body = "Features that enable users to continue to access their documents or add new channels to access them."
      }
    ["access", "privacy"] ->
      { title = "Privacy"
      , body = "Features that support or enable access maintaining or imporving privacy"
      }
    ["access", "mobile"] ->
      { title = "Mobile"
      , body = "Mobile website allowing users to scan & access documents with their phone"
      }
    ["access", "mobile", "native"] ->
      { title = "Native clients"
      , body = "Deliver the mobile web app in an native app container for a more integrated UX."
      }
    ["access", "privacy", "sbc"] ->
      { title = "Managed self hosting"
      , body = "Combined software & hardware package (i.e. Raspberry Pi) that can be used to self host without technical knowledge"
      }
    ["access", "backup"] ->
      { title = "Backup"
      , body = "Different solutions enabling users to back up their data in case of their hosting setup breaking."
      }
    ["access", "backup", "cloud"] ->
      { title = "Enrcypted cloud backup"
      , body = "Support syncing an encrypted copy to another folder that's synced to the cloud (e.g. iCloud, DropBox)"
      }
    ["access", "backup", "usb"] ->
      { title = "External plugin backup"
      , body = "For a headless install: Support automatic sync to a USB storage device that gets plugged in"
      }
    _ ->
      { title = "missing"
      , body = ""
      }



-- Data loading and processing


init : ( Model, Cmd Msg )
init =
    ( case convertCsv featuresStr of
        Ok rawData -> loadData rawData
        _ -> Loading
    , Cmd.none
    )

convertCsv : String -> Result String Data
convertCsv csv  =
  let
     decodeResult = Csv.decodeCsv Csv.NoFieldNames decoder csv
  in
  case decodeResult of
      Ok res ->
        let
           t1 =  Tree.stratifyWithPath
                    { path = \item -> List.Extra.inits item.sequence
                    , createMissingNode = \path -> { sequence = List.Extra.last path |> Maybe.withDefault [], visits = 0 }
                    }
                    res
        in
           case t1 of
              Err _ -> Err "err on t1"
              Ok t -> Ok <| ttt t
        

      _ ->
        Err "bang!"

ttt = 
                (Tree.sumUp identity
                    (\node children ->
                        { node | visits = List.sum (List.map .visits children) }
                    )
                    >> Tree.map
                        (\d ->
                            { sequence = d.sequence
                            , visits = d.visits
                            , category = List.Extra.last d.sequence |> Maybe.withDefault "end"
                            }
                        )
                    >> Tree.sortWith (\_ a b -> compare (Tree.label b).visits (Tree.label a).visits)
                ) 

  


decoder : Csv.Decoder { sequence : List String, visits : Int }
decoder =
    Csv.into
        (\sequence count ->
            { sequence = sequence, visits = count }
        )
        |> Csv.pipeline (Csv.map (String.split "-") (Csv.column 0 Csv.string))
        |> Csv.pipeline (Csv.column 1 Csv.int)


loadData rawData =
            let
                categories =
                    Tree.foldl (\{ sequence } set -> Set.union set <| Set.fromList sequence) Set.empty rawData

                depth =
                    Tree.depth rawData

                f ( currentTop, mapping ) ancestors l c =
                    case ancestors of
                        [ _ ] ->
                            let
                                asS =
                                    ( currentTop + 1, List.length ancestors, String.join "-" l.sequence )

                            in
                            Continue
                                ( currentTop + 1
                                , asS :: mapping
                                )

                        _ ->
                            let
                                asS =
                                    ( currentTop, List.length ancestors, Maybe.withDefault "missing" <| List.head <| List.reverse l.sequence )

                            in
                            Continue
                                ( currentTop
                                , asS :: mapping
                                )

                colorMapping =
                    Debug.log "BF" <| Tuple.second <| Tree.depthFirstFold f ( 0, [] ) rawData
                gradients = [ Scale.Color.tealInterpolator, Scale.Color.lightOrangeInterpolator, Scale.Color.warmGreysInterpolator ]

                labelWithColor (top, d, label) =
                  let
                      gradient = 
                        Maybe.withDefault Scale.Color.tealInterpolator <| List.head <| List.drop top gradients
                      depthFloat = (toFloat d) / (toFloat depth)
                  in
                    (label, gradient depthFloat)
                    
                labelsWithColors =
                  List.map labelWithColor colorMapping
                (labels, colors) = List.foldr (\(l,c) (ls, cs) -> (l::ls, c::cs)) ([],[]) labelsWithColors
                colorScale = Scale.ordinal colors labels
            in
             Loaded
                { layout =
                    Debug.log "rawData" rawData
                        |> Hierarchy.partition [ Hierarchy.size (2 * pi) (radius * radius) ] (.visits >> toFloat)
                        |> Tree.toList
                        |> List.tail
                        |> Maybe.withDefault []
                , categories = labels
                , total = toFloat (Tree.label rawData).visits
                , hovered = Nothing
                , colorScale = colorScale
                }
            

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( Hover hover, Loaded mod ) ->
            ( Loaded { mod | hovered = hover }, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- Visualization


colorScale_ : OrdinalScale String Color
colorScale_ =
    Scale.ordinal (Color.rgb 0.5 0.5 0.5 :: Scale.Color.tableau10) [ "end", "home", "product", "search", "account", "other" ]


mkColorScale : List String -> OrdinalScale String Color
mkColorScale list =
    Scale.ordinal (Color.rgb 0.5 0.5 0.5 :: Scale.Color.tableau10) list


view : Model -> Html Msg
view model =
    case model of
        Loaded data ->
          figure [] [
            svg [ viewBox 0 0 w h, class ["features-sunburst"] ]
                [ sunburst data
                ]
                ]

        Loading ->
            text "loading"

sunburst : LoadedModel -> Svg Msg
sunburst model =
    let
        hovered =
            case model.hovered of
                Just { sequence } ->
                    List.Extra.inits sequence
                        |> Set.fromList

                Nothing ->
                    Set.empty

        opacity seq =
            TypedSvg.Attributes.fillOpacity
                (Opacity
                    (if
                        case model.hovered of
                            Just _ ->
                                Set.member seq hovered

                            Nothing ->
                                True
                     then
                        0.8

                     else
                        0.3
                    )
                )
    in
    g [ transform [ Translate radius radius ] ]
        [ g []
            (model.layout
                |> List.map
                    (\item ->
                        Path.element (arc item)
                            [ opacity item.node.sequence
                            , fill (Paint (Scale.convert model.colorScale item.node.category |> Maybe.withDefault Color.black))
                            , TypedSvg.Attributes.id <| "cat-" ++ ( Maybe.withDefault "" <| List.head <| List.reverse item.node.sequence)
                            ]
                    )
            )
        , g []
          <| List.map (\label -> text_ [dy <| Num 28] 
            [textPath 
              [href <| "#cat-" ++ label
              , startOffset "15%"
              , alignmentBaseline AlignmentCentral 
              , textAnchor AnchorMiddle
              , class ["categoryLabel"]
              -- TypedSvg.Attributes.InPx.fontSize 28, y -8 
              ] [ text label]
            ]) model.categories
        , Svg.Lazy.lazy2 mouseInteractionArcs model.layout model.total
        , case model.hovered of
            Just { percentage, sequence } ->
              let
                  {title, body} = featureDescription sequence
              in
              
                g [ textAnchor AnchorMiddle, TypedSvg.Attributes.fontFamily [ "sans-serif" ], fill (Paint (Color.rgb 0.5 0.5 0.5)) ]
                    [ text_ [ TypedSvg.Attributes.InPx.fontSize 18, y -40 ] [ text title ]
                    , paragraph  30 [y -20 ] body
                    ]

            Nothing ->
                text ""
        ]

paragraph maxLength attrs str =
  let
      mkLine l = tspan [dy <| Num 15, x 0] [text l]
      lines = List.map mkLine <| wrapWords maxLength str
  in
    text_ attrs lines
  

wrapWords : Int -> String -> List String
wrapWords maxLength str =
    let
        words = String.words str

        foldFunction word ( currentLine, acc ) =
            let
                newLine = if String.isEmpty currentLine then word else currentLine ++ " " ++ word
            in
            if String.length newLine <= maxLength then
                ( newLine, acc )
            else
                ( word, acc ++ [ currentLine ] )
    in
    case List.foldl foldFunction ( "", [] ) words of
        ( "", acc ) ->
            acc

        ( lastLine, acc ) ->
            acc ++ [ lastLine ]

mouseInteractionArcs : List LayedOutDatum -> Float -> Svg Msg
mouseInteractionArcs segments total =
    g [ TypedSvg.Attributes.pointerEvents "all", TypedSvg.Events.onMouseLeave (Hover Nothing) ]
        (segments
            |> List.map
                (\item ->
                    Path.element (mouseArc item)
                        [ fill PaintNone
                        , TypedSvg.Events.onMouseEnter
                            (Hover
                                (Just
                                    { sequence = item.node.sequence
                                    , percentage = 100 * item.value / total
                                    }
                                )
                            )
                        ]
                )
        )


arc : LayedOutDatum -> Path
arc s =
    Shape.arc
        { innerRadius = sqrt s.y
        , outerRadius = sqrt (s.y + s.height) - 1
        , cornerRadius = 0
        , startAngle = s.x
        , endAngle = s.x + s.width
        , padAngle = 1 / radius
        , padRadius = radius
        }


mouseArc : LayedOutDatum -> Path
mouseArc s =
    Shape.arc
        { innerRadius = sqrt s.y
        , outerRadius = radius
        , cornerRadius = 0
        , startAngle = s.x
        , endAngle = s.x + s.width
        , padAngle = 0
        , padRadius = 0
        }


format : Float -> String
format f =
    String.left 5 (String.fromFloat f) ++ "%"
