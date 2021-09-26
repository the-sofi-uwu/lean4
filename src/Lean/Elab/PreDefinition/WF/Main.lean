/-
Copyright (c) 2021 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura
-/
import Lean.Elab.PreDefinition.Basic
import Lean.Elab.PreDefinition.WF.TerminationBy
import Lean.Elab.PreDefinition.WF.PackDomain
import Lean.Elab.PreDefinition.WF.PackMutual
import Lean.Elab.PreDefinition.WF.Rel
import Lean.Elab.PreDefinition.WF.Fix

namespace Lean.Elab
open WF
open Meta

def wfRecursion (preDefs : Array PreDefinition) (wfStx? : Option Syntax) : TermElabM Unit := do
  let unaryPreDef ← withoutModifyingEnv do
    for preDef in preDefs do
      addAsAxiom preDef
    let unaryPreDefs ← packDomain preDefs
    for preDef in unaryPreDefs do
      check preDef.value -- TODO: remove
      trace[Elab.definition.wf] "{preDef.declName}, {preDef.levelParams}, {preDef.value}"
    let unaryPreDef ← packMutual unaryPreDefs
    trace[Elab.definition.wf] "{unaryPreDef.declName} := {unaryPreDef.value}"
    return unaryPreDef
  let wfRel ← elabWFRel unaryPreDef wfStx?
  trace[Elab.definition.wf] "{wfRel}"
  let preDefNonRec ← withoutModifyingEnv do
    addAsAxiom unaryPreDef
    mkFix unaryPreDef wfRel
  addNonRec preDefNonRec
  -- TODO: define preDefs
  -- addAndCompilePartialRec preDefs

builtin_initialize registerTraceClass `Elab.definition.wf

end Lean.Elab
