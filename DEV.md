# Dev Notes

## apipe

`apipe` is an asynchronous pipeline within Loom that executes tasks concurrently.
The implementation is inspired by the pipeline system
from [lazy.nvim](https://github.com/fole/lazy.nvim) by Folke, which is used
for managing plugin-related tasks. This pipeline allows for efficient task management,
ensuring that multiple processes can run in parallel without blocking the main workflow.

LazySpecLoader -> core.plugin, loads specs
LazyMeta -> has spec as LazySpecLoader

Usage:

Renames:

LazyCoreConfig: apipe.core.config
LazyConfig: apipe.Config
LazySpec: apipe.LazySpec
LazySpecLoader: apipe.LazyTargetLoader
LazyMeta: apipe.LazyMeta
LazyFragment: apipe.LazyFragment
LazyFragments: apipe.LazyFragments

Config.plugins: Config.targets (key-value pairs of targets)

Objects:

apipe.Task:apipe.IAsyncBase
apipe.Process:apipe.IAsyncBase
apipe.Runner._running:apipe.IAsyncBase

#### Pipelines

##### Create Package

The `create` pipeline is used to create a new package in the project's
workspace folder.

#### TODO


#### Classes

##### Config

The config object is central and holds all references to targets.

`apipe.target.spec`: load(): Creates a Spec objects and sets references in config objects

##### Runner

The runner is responsible for running a pipeline.

##### Task

A Task is a single step of a pipeline. The Task operates on a Target.

##### Target

The entity primarily represents the object or resource that tasks are meant to act upon.

```lua

  _= {
    dep = true,
    frags = { 36 },
    handlers = {},
    installed = true,
    tasks = {},
    working = false
  },
  dependencies = { "friendly-snippets" },
  dir = "/Users/al/.local/share/nvim/lazy/nvim-snippets",
  lazy = true,
  name = "nvim-snippets",
  url = "<https://github.com/garymjr/nvim-snippets.git>",
  <metatable> = {
    __index = { "garymjr/nvim-snippets",
      dependencies = { "rafamadriz/friendly-snippets" },
      opts = {
        friendly_snippets = true
      }
    }
  }
}

```

```
