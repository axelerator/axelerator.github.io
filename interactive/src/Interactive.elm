module Interactive exposing (main)

import Browser
import Features
import FeatureTree
import Subscribe
import Unsubscribe
import Html
import Json.Decode as Decode exposing (Decoder)
import Variants
import Shape

type Flags
  = InitVariants String
  | InitFeatures String
  | InitFeatureTree
  | InitSubscribe
  | InitUnsubscribe String

decodeFlags : Decoder Flags
decodeFlags =
 Decode.field "kind" Decode.string
  |> Decode.andThen (\kind ->
    case kind of
        "Variants" -> 
          Decode.map InitVariants (Decode.field "lang" Decode.string)
        "Features" -> Decode.map InitFeatures (Decode.field "lang" Decode.string)
        "FeatureTree" -> Decode.succeed InitFeatureTree
        "Subscribe" -> Decode.succeed InitSubscribe
        "Unsubscribe" -> Decode.map InitUnsubscribe (Decode.field "email" Decode.string)
        _ -> Decode.fail <| "Unknown variant: " ++ kind
  )



main : Program Decode.Value Model Msg
main =
    Browser.element
        { init = init 
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init v =
  case Decode.decodeValue decodeFlags v of
      Ok (InitVariants lang) ->
        ( OnVariants <| Variants.init lang
        , Cmd.none
        )
      Ok InitFeatureTree ->
        ( OnFeatureTree <| FeatureTree.init
        , Cmd.none
        )
      Ok (InitFeatures lang)->
        let
           (m, c) = Features.init lang
        in
        
        ( OnFeatures <| m
        , Cmd.map ForFeatures c
        )
      Ok InitSubscribe ->
        ( OnSubscribe <| Subscribe.init
        , Cmd.none
        )
      Ok (InitUnsubscribe email) ->
        ( OnUnsubscribe <| Unsubscribe.init email
        , Cmd.none
        )
      _ ->
        ( OnVariants <| Variants.init "en"
        , Cmd.none
        )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type Model
    = OnVariants Variants.Model
    | OnFeatures Features.Model
    | OnFeatureTree FeatureTree.Model
    | OnSubscribe Subscribe.Model
    | OnUnsubscribe Unsubscribe.Model


type Msg
    = ForVariants Variants.Msg
    | ForFeatureTree FeatureTree.Msg
    | ForFeatures Features.Msg
    | ForSubscribe Subscribe.Msg
    | ForUnsubscribe Unsubscribe.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ForVariants msg_, OnVariants model_ ) ->
            let
                ( model__, cmd ) =
                    Variants.update msg_ model_
            in
            ( OnVariants model__, Cmd.map ForVariants cmd )

        ( ForFeatureTree msg_, OnFeatureTree model_ ) ->
            let
                ( model__, cmd ) =
                    FeatureTree.update msg_ model_
            in
            ( OnFeatureTree model__, Cmd.map ForFeatureTree cmd )

        ( ForFeatures msg_, OnFeatures model_ ) ->
            let
                ( model__, cmd ) =
                    Features.update msg_ model_
            in
            ( OnFeatures model__, Cmd.map ForFeatures cmd )
        ( ForSubscribe msg_, OnSubscribe model_ ) ->
            let
                ( model__, cmd ) =
                    Subscribe.update msg_ model_
            in
            ( OnSubscribe model__, Cmd.map ForSubscribe cmd )

        ( ForUnsubscribe msg_, OnUnsubscribe model_ ) ->
            let
                ( model__, cmd ) =
                    Unsubscribe.update msg_ model_
            in
            ( OnUnsubscribe model__, Cmd.map ForUnsubscribe cmd )

        _ ->
            ( model
            , Cmd.none
            )


view model =
    case model of
        OnVariants model_ ->
            Html.map ForVariants <| Variants.view model_

        OnFeatureTree model_ ->
            Html.map ForFeatureTree <| FeatureTree.view model_

        OnFeatures model_ ->
            Html.map ForFeatures <| Features.view model_

        OnSubscribe model_ ->
            Html.map ForSubscribe <| Subscribe.view model_

        OnUnsubscribe model_ ->
            Html.map ForUnsubscribe <| Unsubscribe.view model_
