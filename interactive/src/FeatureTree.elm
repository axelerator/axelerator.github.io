module FeatureTree exposing (Model, Msg, init, update, view)

import Color exposing (rgba)
import Curve
import Hierarchy
import List.Extra
import Path exposing (Path)
import Shape
import Tree exposing (Tree)
import TypedSvg exposing (circle, g, image, rect, svg)
import TypedSvg.Attributes exposing (cx, cy, d, dx, dy, fill, href, id, noFill, pointerEvents, r, stdDeviation, stroke, strokeDasharray, strokeWidth, style, textAnchor, textLength, transform, viewBox)
import TypedSvg.Attributes.InPx exposing (fontSize, height, width, x, y)
import TypedSvg.Core exposing (Svg)
import TypedSvg.Events
import TypedSvg.Filters.Attributes exposing (floodOpacity)
import TypedSvg.Types exposing (AnchorAlignment(..), ClipPath(..), Length(..), Opacity(..), Paint(..), Transform(..), em, num, px)
import Zoom exposing (Zoom)
import Tree exposing (tree)


type alias Model = ()


type alias Msg = ()


init = ()


update _ model =
    ( model, Cmd.none )


view model =
    svg
        [ viewBox -50 -25 100 50
        , TypedSvg.Attributes.class [ "features" ]
        ]
        [g []
          (List.map toPath <| Debug.log "layout" layout)
        ]

toPath d = Path.element (arc d) [ fill (Paint d.node) ]

type alias LayedOutDatum =
    { x : Float
    , y : Float
    , width : Float
    , height : Float
    , value : Float
    , node : Color.Color
    }
featureTree = 
  tree Color.red
          [ tree Color.blue []
          , tree Color.green []
          ]

featureTree_ = 
  tree "Document Storage"
      [ tree "Retrival"
          [ tree "Sender tracking" []
          , tree "Tagging" []
          ]
      , tree "Productivity" 
          [ tree "Tasks" [] ]
      , tree "Access"
          [ tree "Privacy" []
          , tree "Backups" []
          ]
      ]

layout : List LayedOutDatum
layout = 
  Hierarchy.partition [ Hierarchy.size (2 * pi) (radius * radius) ] (\n -> 23) featureTree
  |> Tree.toList

--  |> List.tail
--  |> Maybe.withDefault []

radius = 15

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


