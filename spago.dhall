{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name =
    "my-project"
, dependencies =
    [ "aff-promise"
    , "bouzuya-command-line-option-parser"
    , "console"
    , "effect"
    , "node-fs"
    , "node-path"
    , "node-process"
    , "psci-support"
    , "simple-json"
    , "test-unit"
    ]
, packages =
    ./packages.dhall
}
