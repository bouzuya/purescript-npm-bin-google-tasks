module Command.Task.Command.List
  ( command
  ) where

import Prelude

import Command.Task.Command.List.Options as Options
import Data.Either as Either
import Effect (Effect)
import Effect.Class.Console as Console
import Effect.Exception as Exception

command :: Array String -> Effect Unit
command args = do
  { options } <-
    Either.either Exception.throw pure (Options.parse args)
  if options.help
    then Console.log Options.help
    else Console.logShow options
