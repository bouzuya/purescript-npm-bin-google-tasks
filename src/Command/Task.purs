module Command.Task
  ( command
  ) where

import Prelude

import Command.Task.Command.Get as CommandGet
import Command.Task.Command.List as CommandList
import Command.Task.Options as Options
import Data.Array as Array
import Data.Either as Either
import Effect (Effect)
import Effect.Class.Console as Console
import Effect.Exception as Exception

command :: Array String -> Effect Unit
command args = do
  { arguments, options } <-
    Either.either Exception.throw pure (Options.parse args)
  if options.help
    then Console.log Options.help
    else
      case Array.take 1 arguments of
        ["help"] -> Console.log Options.help
        ["get"] -> CommandGet.command (Array.drop 1 arguments)
        ["list"] -> CommandList.command (Array.drop 1 arguments)
        _ -> do
          Console.logShow arguments
          Console.logShow options
