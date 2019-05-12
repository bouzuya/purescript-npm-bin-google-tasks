{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name =
    "my-project"
, dependencies =
    [ "aff-promise"
    , "bouzuya-command-line-option-parser"
    , "bouzuya-template-string"
    , "node-fs"
    , "node-process"
    , "psci-support"
    , "simple-json"
    , "test-unit"
    ]
, packages =
    ./packages.dhall
}
