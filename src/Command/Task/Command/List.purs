module Command.Task.Command.List
  ( command
  ) where

import Prelude

import Bouzuya.TemplateString as TemplateString
import Command.Task.Command.List.Options (Options)
import Command.Task.Command.List.Options as Options
import Command.Task.TaskResource (TaskResource)
import Control.Monad.Rec.Class as MonadRec
import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Either as Either
import Data.Maybe (Maybe(..))
import Data.Maybe as Maybe
import Data.String as String
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect as Effect
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
import Record as Record
import Simple.JSON as SimpleJSON

foreign import data Client :: Type
foreign import listTasksImpl :: Foreign -> Client -> Effect (Promise Foreign)
foreign import newClientImpl :: String -> String -> Effect Client

type Response a =
  { config :: {} -- FIXME
  , data :: a
  , headers :: Object String
  , status :: Int
  , statusText :: String
  }

type TaskListParams =
  { completedMax :: Maybe String
  , completedMin :: Maybe String
  , dueMax :: Maybe String
  , dueMin :: Maybe String
  , maxResults :: Maybe Int
  , pageToken :: Maybe String
  , showCompleted :: Maybe Boolean
  , showDeleted :: Maybe Boolean
  , showHidden :: Maybe Boolean
  , tasklist :: String
  , updatedMin :: Maybe String
  }

type TaskListResponse =
  { etag :: String
  , items :: Array TaskResource
  , kind :: String -- "tasks#tasks"
  , nextPageToken :: Maybe String
  }

command :: Array String -> Effect Unit
command args = do
  { options } <-
    Either.either Exception.throw pure (Options.parse args)
  if options.help
    then Console.log Options.help
    else Aff.launchAff_ do
      client <- liftEffect (newClient ".") -- FIXME
      tasks <-
        listAllTasks
          { completedMax: options.completedMax
          , completedMin: options.completedMin
          , dueMax: options.dueMax
          , dueMin: options.dueMin
          , maxResults: Just 100
          , pageToken: Nothing
          , showCompleted: Just options.showCompleted
          , showDeleted: Just options.showDeleted
          , showHidden: Just options.showHidden
          , tasklist: options.taskListId
          , updatedMin: options.updatedMin
          }
          client
      liftEffect (Effect.foreachE tasks (Console.log <<< (format options)))

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

listAllTasks :: TaskListParams -> Client -> Aff (Array TaskResource)
listAllTasks options client =
  MonadRec.tailRecM go { pageToken: Nothing, tasks: [] }
  where
    go { pageToken, tasks } = do
      { data: { items, nextPageToken } } <-
        listTasks (Record.merge { pageToken } options) client
      let tasks' = tasks <> items
      pure
        (case nextPageToken of
          Nothing ->
            MonadRec.Done tasks'
          Just _ ->
            MonadRec.Loop { pageToken: nextPageToken, tasks: tasks' })

listTasks :: TaskListParams -> Client -> Aff (Response TaskListResponse)
listTasks options client = do
  response <- Promise.toAffE (listTasksImpl (SimpleJSON.write options) client)
  Class.liftEffect
    (Either.either (Exception.throw <<< show) pure (SimpleJSON.read response))

newClient :: String -> Effect Client
newClient dir = do
  credentials <-
    FS.readTextFile Encoding.UTF8 (Path.concat [dir, "credentials.json"])
  token <-
    FS.readTextFile Encoding.UTF8 (Path.concat [dir, "token.json"])
  newClientImpl credentials token
