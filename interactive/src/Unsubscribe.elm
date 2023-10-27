module Unsubscribe exposing (init, Model, Msg, update, view)
import Html exposing (div)
import Html exposing (text)
import Html exposing (p)
import Html exposing (form)
import Html exposing (input)
import Html exposing (button)
import Html.Attributes exposing (type_)
import Html.Attributes exposing (required)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Html.Attributes exposing (value)
import Html.Attributes exposing (disabled)
import Html.Events exposing (onInput)
import Html.Events exposing (onSubmit)
import Http exposing (post)

type Model 
  = Input String
  | Pending String
  | Success
  | Failure

  
type Msg 
  = GotSubscriptionResponse (Result Http.Error ())
  | ChangeEmail String
  | Submit


init email = Input email

update msg model = 
  case msg of
    ChangeEmail email ->
      ( Input email, Cmd.none)
    Submit ->
      let
          email =
            case model of
                Input email_ -> email_
                _ -> ""
      in
      
      ( Pending email, postSubscription email )
    GotSubscriptionResponse res ->
      case res of
          Err _ ->
            (Failure, Cmd.none)
          Ok _ ->
            (Success, Cmd.none)


view model = 
  case model of
      Input v ->
        div [] 
          [p [] [text "Want to get a weekly digest?"]
          , form [onSubmit Submit] 
            [ input [type_ "email", required True, value v, onInput ChangeEmail] []
            , button [] [text "Unsubscribe"]
            ]
          ]
      Pending v ->
        div [] 
          [p [] [text "Want to get a weekly digest?"]
          , form [] 
            [ input [type_ "email", required True, value v] []
            , button [disabled True] [text "Unsubscribe"]
            ]
          ]
      Success ->
        div [] 
          [p [] [text "Success, feel free to come back any time!" ]]
      Failure ->
        div [] 
          [p [] [text "Opps, something went wrong" ]]



postSubscription : String -> Cmd Msg
postSubscription email =
  Http.post
    { url = "http://localhost:8080/unsubscribe"
    , body = Http.jsonBody <| subscriptionEncoder email
    , expect = Http.expectWhatever GotSubscriptionResponse 
    }

subscriptionEncoder : String -> Encode.Value
subscriptionEncoder email =
  Encode.object [("email", Encode.string email)]

