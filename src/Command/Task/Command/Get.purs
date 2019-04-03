module Command.Task.Command.Get
  ( command
  ) where

import Prelude

import Bouzuya.TemplateString as TemplateString
import Command.Task.Command.Get.Options (Options)
import Command.Task.Command.Get.Options as Options
import Command.Task.TaskResource (TaskResource)
import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Either as Either
import Data.Maybe (Maybe)
import Data.Maybe as Maybe
import Data.String as String
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff as Aff
import Effect.Class (liftEffect)
import Effect.Class as Class
import Effect.Class.Console as Console
import Effect.Exception as Exception
import Foreign (Foreign)
import Foreign.Object (Object)
import Foreign.Object as Object
import Node.Encoding as Encoding
import Node.FS.Sync as FS
import Node.Path as Path
import Simple.JSON as SimpleJSON

foreign import data Client :: Type
foreign import getTaskImpl :: Foreign -> Client -> Effect (Promise Foreign)
foreign import newClientImpl :: String -> String -> Effect Client

type Response a =
  { config :: {} -- FIXME
  , data :: a
  , headers :: Object String
  , status :: Int
  , statusText :: String
  }

type TaskParams =
  { task :: String
  , tasklist :: String
  }

command :: Array String -> Effect Unit
command args = do
  { options } <-
    Either.either Exception.throw pure (Options.parse args)
  if options.help
    then Console.log Options.help
    else Aff.launchAff_ do
      client <- liftEffect (newClient ".") -- FIXME
      response <-
        getTask
          { task: options.taskId
          , tasklist: options.taskListId
          }
          client
      liftEffect (Console.log (format options response.data))

format :: Options -> TaskResource -> String
format options task =
  TemplateString.template
    (Maybe.fromMaybe "{{title}} {{id}}" options.format)
    (Object.fromFoldable
      [ Tuple "completed" (Maybe.fromMaybe "" task.completed)
      -- , Tuple "deleted" task.deleted
      , Tuple "due" (formatDue task.due)
      , Tuple "etag" task.etag
      -- , Tuple "hidden" task.hidden
      , Tuple "id" task.id
      , Tuple "kind" task.kind
      -- , Tuple "links" task.links
      , Tuple "notes" (Maybe.fromMaybe "" task.notes)
      , Tuple "parent" (Maybe.fromMaybe "" task.parent)
      , Tuple "position" task.position
      , Tuple "selfLink" task.selfLink
      , Tuple "status" task.status
      , Tuple "title" task.title
      , Tuple "updated" task.updated
      ])

formatDue :: Maybe String -> String
formatDue = Maybe.maybe "9999-99-99" (String.take (String.length "YYYY-MM-DD"))

getTask :: TaskParams -> Client -> Aff (Response TaskResource)
getTask options client = do
  response <- Promise.toAffE (getTaskImpl (SimpleJSON.write options) client)
  Class.liftEffect
    (Either.either (Exception.throw <<< show) pure (SimpleJSON.read response))

newClient :: String -> Effect Client
newClient dir = do
  credentials <-
    FS.readTextFile Encoding.UTF8 (Path.concat [dir, "credentials.json"])
  token <-
    FS.readTextFile Encoding.UTF8 (Path.concat [dir, "token.json"])
  newClientImpl credentials token
