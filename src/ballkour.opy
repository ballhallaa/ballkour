#!mainFile "main.opy"
#!setupTags
# Translated in translations/<language>.po (see tools/translations.py)
#!translations en de es fr it ja ko pl pt ru th tr zh_cn zh_tw
#!disableTranslationSourceLines
# Each player's language is a player variable, set from their game's in Player: Joins, so
# Prev./Next Language can change it. People in spectator slots see English.
#!translateWithPlayerVar noDetectionRule noTlErr
#!useVariableForCompressionAlphabet
#!rulePrefixTemplate f"{$prefix}: {$rule}" if $prefix and $rule else $rule
#!postCompileHook "../../minify.js"

#!include "engine/match.opy"
#!include "engine/players.opy"
#!include "engine/run.opy"
#!include "engine/checkpoints.opy"
# After checkpoints.opy, as the lobby floats above CP 0, which Expand Data unpacks
#!include "engine/lobby.opy"
#!include "engine/hints.opy"
#!include "engine/hint-recorder.opy"
#!include "engine/timers.opy"
#!include "engine/splits.opy"
#!include "engine/movement.opy"
#!include "engine/mistakes.opy"
#!include "engine/bounce-checkpoints.opy"
#!include "engine/completion.opy"
#!include "engine/controls.opy"
#!include "engine/qa.opy"
