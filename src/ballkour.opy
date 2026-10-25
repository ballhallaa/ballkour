#!mainFile "main.opy"
#!setupTags
#!useVariableForCompressionAlphabet
#!rulePrefixTemplate f"{$prefix}: {$rule}" if $prefix and $rule else $rule

#!include "engine/match.opy"
#!include "engine/players.opy"
#!include "engine/lobby.opy"
#!include "engine/run.opy"
#!include "engine/checkpoints.opy"
#!include "engine/hints.opy"
#!include "engine/hint-recorder.opy"
#!include "engine/timers.opy"
#!include "engine/splits.opy"
#!include "engine/movement.opy"
#!include "engine/mistakes.opy"
#!include "engine/bounce-checkpoints.opy"
#!include "engine/completion.opy"
#!include "engine/controls.opy"
