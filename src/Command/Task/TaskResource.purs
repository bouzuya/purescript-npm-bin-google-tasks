module Command.Task.TaskResource
  ( TaskResource
  , TaskResourceParams
  , format
  ) where

import Bouzuya.TemplateString as TemplateString
import Data.Maybe (Maybe)
import Data.Maybe as Maybe
import Data.String as String
import Data.Tuple (Tuple(..))
import Foreign.Object as Object

type TaskResource =
  { completed :: Maybe String -- datetime,
  , deleted :: Maybe Boolean
  , due :: Maybe String -- datetime,
  , etag :: String
  , hidden :: Maybe Boolean
  , id :: String
  , kind :: String -- "tasks#task"
  , links ::
      Maybe
        (Array
          { type :: String
          , description :: String
          , link :: String
          })
  , notes :: Maybe String
  , parent :: Maybe String
  , position :: String
  , selfLink :: String
  , status :: String
  , title :: String
  , updated :: String -- datetime,
  }

type TaskResourceParams =
  { completed :: Maybe String -- datetime,
  , deleted :: Maybe Boolean
  , due :: Maybe String -- datetime,
  , etag :: Maybe String
  , hidden :: Maybe Boolean
  , id :: Maybe String
  , kind :: Maybe String -- "tasks#task"
  , links ::
      Maybe
        (Array
          { type :: String
          , description :: String
          , link :: String
          })
  , notes :: Maybe String
  , parent :: Maybe String
  , position :: Maybe String
  , selfLink :: Maybe String
  , status :: Maybe String
  , title :: Maybe String
  , updated :: Maybe String -- datetime,
  }

format :: Maybe String -> TaskResource -> String
format template task =
  TemplateString.template
    (Maybe.fromMaybe "{{title}} {{id}}" template)
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
