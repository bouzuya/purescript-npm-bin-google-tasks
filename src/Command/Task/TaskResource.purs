module Command.Task.TaskResource
  ( TaskResource
  ) where

import Data.Maybe (Maybe)

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
