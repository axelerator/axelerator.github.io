module Variants exposing (Model, Msg, init, update, view)

import Color
import Html exposing (Html, button, div, h1, h2, h3, h4, img, input, li, p, section, table, td, text, th, thead, tr, ul)
import Html.Attributes exposing (attribute, class, classList, max, min, src, style, type_, value)
import Html.Events exposing (onClick, onInput)
import String exposing (fromFloat)
import TypedSvg exposing (circle, g, image, svg)
import TypedSvg.Attributes exposing (cx, cy, d, fill, height, r, stdDeviation, stroke, strokeDasharray, strokeWidth, transform, viewBox, width)
import TypedSvg.Core exposing (Svg)
import TypedSvg.Filters.Attributes exposing (floodOpacity)
import TypedSvg.Types exposing (Length(..), Opacity(..), Paint(..), Transform(..), px)


type alias Model =
    { count : Int
    , package : Package
    }


init : Model
init =
    { count = 0, package = Pi False }


type Msg
    = Increment
    | ChangeSlider String


type Package
    = Operator
    | Pi Bool
    | SaaS


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | count = model.count + 1 }
            , Cmd.none
            )

        ChangeSlider s ->
            let
                package =
                    case s of
                        "0" ->
                            Operator

                        "1" ->
                            Pi False

                        _ ->
                            SaaS
            in
            ( { model | package = package }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


type Components
    = Datacenter
    | Cloud
    | Flashdrive
    | Laptop
    | Micro
    | Phone
    | Router


inPos : Package -> Components -> ( Float, Float )
inPos package c =
    case c of
        Cloud ->
            ( 0.6, 0.12 )

        Datacenter ->
            ( 0.8, 0.3 )

        Laptop ->
            ( 0.05, 0.3 )

        Phone ->
            case package of
                SaaS ->
                    ( 0.6, 0.45 )

                _ ->
                    ( 0.3, 0.15 )

        Router ->
            ( 0.4, 0.3 )

        Flashdrive ->
            ( 0.5, 0.8 )

        Micro ->
            ( 0.18, 0.47 )


type alias Flow =
    ( Components, Components )


type alias Setup =
    { components : List Components
    , flows : List Flow
    }


allComponents =
    [ Laptop, Phone, Router, Micro, Cloud, Datacenter, Flashdrive ]


setup : Package -> Setup
setup p =
    case p of
        Operator ->
            { components = [ Laptop, Phone ]
            , flows = [ fLaptopPhone ]
            }

        Pi _ ->
            { components = [ Laptop, Phone, Router, Micro ]
            , flows = [ fMicroRouter, fLaptopRouter, fPhoneRouter ]
            }

        SaaS ->
            { components = [ Laptop, Phone, Router, Datacenter, Cloud ]
            , flows = [ fLaptopRouter, fRouterCloud, fCloudDatacenter, fPhoneCloud ]
            }


fLaptopPhone =
    ( Laptop, Phone )


fLaptopRouter =
    ( Laptop, Router )


fPhoneRouter =
    ( Phone, Router )


fMicroRouter =
    ( Micro, Router )


fRouterCloud =
    ( Router, Cloud )


fPhoneCloud =
    ( Phone, Cloud )


fCloudDatacenter =
    ( Cloud, Datacenter )


allFlows =
    [ fLaptopPhone, fLaptopRouter, fPhoneRouter, fMicroRouter, fRouterCloud, fPhoneCloud, fCloudDatacenter ]


compSrc c =
    "/assets/interactive/"
        ++ (case c of
                Datacenter ->
                    "datacenter.svg"

                Flashdrive ->
                    "flashdrive.svg"

                Laptop ->
                    "laptop.svg"

                Micro ->
                    "micro.svg"

                Phone ->
                    "phone.svg"

                Router ->
                    "router.svg"

                Cloud ->
                    "cloud.svg"
           )


view : Model -> Html Msg
view model =
    let
        selfHostedSelected =
            model.package == Operator

        piSelected =
            case model.package of
                Pi _ ->
                    True

                _ ->
                    False

        saasSelected =
            model.package == SaaS

        sliderPos =
            case model.package of
                Operator ->
                    "0"

                Pi _ ->
                    "1"

                SaaS ->
                    "2"
        pt = packageTable selfHostedSelected piSelected saasSelected
    in
    section []
        [ viewComps model.package
        , p [ class "slider" ]
            [ div [] [ text "Privacy" ]
            , input [ type_ "range", value sliderPos, Html.Attributes.min "0", Html.Attributes.max "2", onInput ChangeSlider ] []
            , div [] [ text "Comfort" ]
            ]
        , p [ class "packages" ]
            (pt True ++ pt False)
        ]

packageTable selfHostedSelected piSelected saasSelected overlapping =
            [ div [ classList [ ( "overlapping", overlapping ), ( "selected", selfHostedSelected ) ] ]
                [ h3 [] [ text "Solo" ]
                , ul []
                    [ li [] [ text "Maximum privacy" ]
                    , li [] [ text "Runs on your computer" ]
                    , li [] [ text "Make backups yourself (iCloud/DropBox/Google Drive)" ]
                    ]
                ]
            , div [ classList [ ( "overlapping", overlapping ), ( "selected", piSelected ) ] ]
                [ h3 [] [ text "Managed Self Host" ]
                , ul []
                    [ li [] [ text "You get a microcomputer with Software preinstalled" ]
                    , li [] [ text "Plug it into your Wifi router" ]
                    , li [] [ text "Access from all devices in your home" ]
                    , li [] [ text "Nobody has access from the internet" ]
                    ]
                ]
            , div [ classList [ ( "overlapping", overlapping ), ( "selected", saasSelected ) ] ]
                [ h3 [] [ text "Cloud" ]
                , ul []
                    [ li [] [ text "Maximum comfort" ]
                    , li [] [ text "Monthly subscription" ]
                    , li [] [ text "No installation needed" ]
                    , li [] [ text "Data is stored & backed up in the Cloud" ]
                    ]
                ]
            ]

flowsView : Package -> Html msg
flowsView package =
    let
        flowsWithVisibility =
            List.map (\f -> ( List.member f flows, f )) allFlows

        { components, flows } =
            setup package

        compsWithVisibility =
            List.map (\c -> ( List.member c components, c )) allComponents

        house =
            image
                [ TypedSvg.Attributes.href "/assets/interactive/house.svg"
                , width <| Num 120
                , height <| Num 120
                , style "opacity" "0.2"
                , TypedSvg.Attributes.x <| Num -50
                , TypedSvg.Attributes.y <| Num -40
                ]
                []

        defs =
            TypedSvg.defs []
                [ TypedSvg.filter [ TypedSvg.Attributes.id "shadow" ]
                    [ TypedSvg.Core.node "feDropShadow"
                        [ TypedSvg.Attributes.dx <| Num 1
                        , TypedSvg.Attributes.dy <| Num 1
                        , stdDeviation "0.9"
                        , TypedSvg.Core.attribute "flood-opacity" "0.3"
                        ]
                        []
                    ]
                ]
    in
    svg
        [ viewBox 0 15 100 50, TypedSvg.Attributes.class [ "flows" ] ]
    <|
        defs
            :: house
            :: List.map (viewFlow package) flowsWithVisibility
            ++ List.map (viewComp package) compsWithVisibility


compSize =
    0.23


halfCompSize =
    0.23 * 0.5


svgPos : ( Float, Float ) -> String
svgPos ( x, y ) =
    fromFloat ((x + halfCompSize) * 100.0) ++ " " ++ fromFloat ((halfCompSize + y) * 100.0)


svgPrefixed : ( String, ( Float, Float ) ) -> String
svgPrefixed ( p, pos ) =
    p ++ " " ++ svgPos pos


dElem es =
    d <| String.join " " <| List.map svgPrefixed es


viewFlow : Package -> ( Bool, Flow ) -> Svg msg
viewFlow package ( visible, ( from, to ) ) =
    let
        fromPos =
            inPos package from

        ( fx, fy ) =
            fromPos

        ( tx, ty ) =
            toPos

        toPos =
            inPos package to

        ( c1, c2 ) =
            if ty < fy then
                ( ( tx, fy )
                , ( fx, ty )
                )

            else
                ( ( tx, fy )
                , ( fx, ty )
                )

        pth dir =
            TypedSvg.path
                [ dElem
                    [ ( "M", fromPos )
                    , ( "C", c1 )
                    , ( ",", c2 )
                    , ( ",", toPos )
                    ]
                , TypedSvg.Attributes.class
                    [ "flow"
                    , if dir then
                        "in"

                      else
                        "out"
                    ]
                , fill <| PaintNone
                , strokeWidth (px 0.3)
                , stroke <|
                    Paint <|
                        if dir then
                            Color.rgba 0.8 0 0 1.0

                        else
                            Color.rgba 0 0.8 0.8 1.0
                , TypedSvg.Attributes.opacity
                    (Opacity <|
                        if visible then
                            1.0

                        else
                            0.0
                    )
                , if dir then
                    TypedSvg.Attributes.transform [ Translate 1.0 1.0 ]

                  else
                    TypedSvg.Attributes.transform []
                ]
                []
    in
    TypedSvg.g []
        [ pth False
        , pth True
        ]


viewComps package =
    p [ class "components foo5" ]
        [ flowsView package ]


pcnt p =
    fromFloat (p * 100.0) ++ "%"


viewComp package ( visible, c ) =
    let
        ( x, y ) =
            inPos package c

        translate =
            transform [ Translate (x * 100) (y * 100) ]

        opacity =
            if visible then
                "1.0"

            else
                "0.0"
    in
    image
        [ TypedSvg.Attributes.href <| compSrc c
        , width <| Num 23
        , height <| Num 23
        , style "opacity" opacity
        , style "filter" "url(#shadow)"
        , TypedSvg.Attributes.x <| Num <| x * 100.0
        , TypedSvg.Attributes.y <| Num <| y * 100.0
        ]
        []
