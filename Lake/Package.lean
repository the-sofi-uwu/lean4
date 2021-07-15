/-
Copyright (c) 2017 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Gabriel Ebner, Sebastian Ullrich, Mac Malone
-/
import Lean.Data.Name
import Lean.Elab.Import
import Lake.LeanVersion
import Lake.BuildTarget

open Lean System

namespace Lake

def defaultSrcDir : FilePath := "."
def defaultBuildDir : FilePath := "build"
def defaultBinDir := defaultBuildDir / "bin"
def defaultLibDir := defaultBuildDir / "lib"
def defaultOleanDir := defaultBuildDir / "lib"
def defaultIrDir := defaultBuildDir / "ir"
def defaultDepsDir : FilePath := "lean_packages"

inductive Source where
  | path (dir : FilePath) : Source
  | git (url rev : String) (branch : Option String) : Source

structure Dependency where
  name : String
  src  : Source
  args : List String := []

structure PackageConfig where
  name : String
  version : String
  moduleRoot : Name := name.capitalize
  leanVersion : String := leanVersionString
  leanArgs : Array String := #[]
  leancArgs : Array String := #[]
  linkArgs : Array String := #[]
  srcDir : FilePath := defaultSrcDir
  oleanDir : FilePath := defaultOleanDir
  irDir : FilePath := defaultIrDir
  binDir : FilePath := defaultBinDir
  binName : String := name
  libDir : FilePath := defaultLibDir
  libName : String := name.capitalize
  depsDir : FilePath := defaultDepsDir
  dependencies : List Dependency := []
  moreDepsTarget : BuildTarget LeanTrace PUnit := BuildTarget.nil
  deriving Inhabited

structure Package where
  dir : FilePath
  config : PackageConfig
  deriving Inhabited

def Packager := FilePath → List String → IO PackageConfig

namespace Package

def name (self : Package) : String :=
  self.config.name

def version (self : Package) : String :=
  self.config.version

def leanVersion (self : Package) : String :=
  self.config.leanVersion

def moduleRoot (self : Package) : Name :=
  self.config.moduleRoot

def moduleRootName (self : Package) : String :=
  self.config.moduleRoot.toString

def dependencies (self : Package) : List Dependency :=
  self.config.dependencies

def moreDepsTarget (self : Package) : BuildTarget LeanTrace PUnit :=
  self.config.moreDepsTarget

def leanArgs (self : Package) : Array String :=
  self.config.leanArgs

def leancArgs (self : Package) : Array String :=
  self.config.leancArgs

def linkArgs (self : Package) : Array String :=
  self.config.linkArgs

def depsDir (self : Package) : FilePath :=
  self.dir / self.config.depsDir

def srcDir (self : Package) : FilePath :=
  self.dir / self.config.srcDir

def srcRoot (self : Package) : FilePath :=
  self.srcDir / FilePath.withExtension self.moduleRootName "lean"

def modToSrc (mod : Name) (self : Package) : FilePath :=
  Lean.modToFilePath self.srcDir mod "lean"

def oleanDir (self : Package) : FilePath :=
  self.dir / self.config.oleanDir

def oleanRoot (self : Package) : FilePath :=
  self.oleanDir / FilePath.withExtension self.moduleRootName "olean"

def modToHashFile (mod : Name) (self : Package) : FilePath :=
  Lean.modToFilePath self.oleanDir mod "hash"

def modToOlean (mod : Name) (self : Package) : FilePath :=
  Lean.modToFilePath self.oleanDir mod "olean"

def irDir (self : Package) : FilePath :=
  self.dir / self.config.irDir

def cDir (self : Package) : FilePath :=
  self.irDir

def modToC (mod : Name) (self : Package) : FilePath :=
  Lean.modToFilePath self.cDir mod "c"

def oDir (self : Package) : FilePath :=
  self.irDir

def modToO (mod : Name) (self : Package) : FilePath :=
  Lean.modToFilePath self.oDir mod "o"

def binDir (self : Package) : FilePath :=
  self.dir / self.config.binDir

def binName (self : Package) : FilePath :=
  self.config.binName

def binFileName (self : Package) : FilePath :=
  FilePath.withExtension self.binName FilePath.exeExtension

def binFile (self : Package) : FilePath :=
  self.binDir / self.binFileName

def libDir (self : Package) : FilePath :=
  self.dir / self.config.libDir

def staticLibName (self : Package) : FilePath :=
  self.config.libName

def staticLibFileName (self : Package) : FilePath :=
  s!"lib{self.moduleRoot}.a"

def staticLibFile (self : Package) : FilePath :=
  self.libDir / self.staticLibFileName
