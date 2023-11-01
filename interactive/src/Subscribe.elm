module Subscribe exposing (init, Model, Msg, update, view)
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


init = Input ""

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
          [ form [onSubmit Submit] 
            [ input [type_ "email", required True, value v, onInput ChangeEmail] []
            , button [] [text "Subscribe"]
            ]
          ]
      Pending v ->
        div [] 
          [ form [] 
            [ input [type_ "email", required True, value v] []
            , button [disabled True] [text "Subscribe"]
            ]
          ]
      Success ->
        div [] 
          [p [] [text "Success, great to have you onboard!" ]]
      Failure ->
        div [] 
          [p [] [text "Opps, something went wrong" ]]



postSubscription : String -> Cmd Msg
postSubscription email =
  Http.post
    { url = "https://newsletter.axelerator.de/subscribe"
    , body = Http.jsonBody <| subscriptionEncoder email
    , expect = Http.expectWhatever GotSubscriptionResponse 
    }

subscriptionEncoder : String -> Encode.Value
subscriptionEncoder email =
  Encode.object [("email", Encode.string email)]
