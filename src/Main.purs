module Main
  ( main
  ) where

import Prelude

import Data.Array as Array
import Data.Either as Either
import Effect (Effect)
import Effect.Console as Console
import Effect.Exception as Exception
import Node.Process as Process
import Options as Options

main :: Effect Unit
main = do
  args <- map (Array.drop 2) Process.argv
  { arguments, options } <-
    Either.either Exception.throw pure (Options.parse args)
  Console.logShow arguments
  Console.logShow options
