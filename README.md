# NL for Visual Studio Code

Language support for [NL](https://github.com/nl-lang/nl), the scripting
language for games and mods that runs on LuaJIT.

- **Syntax highlighting** for `.nl` and `.d.nl` files: keywords, strings with
  `#{…}` interpolation and heredocs, Lua paths (`:string.len`), `@fields`,
  declarations, type annotations, block and short-function parameters.
- **Language server**: diagnostics, hover, go-to-definition and completion
  from `nl-lsp`.
- **Formatting** with `nlc fmt` (Format Document, or format on save).
- Bracket matching, auto-closing pairs, comment toggling and indentation
  rules for `… end` blocks.

## Setup

The extension does not bundle the compiler. Build `nl-lsp` and `nlc` from the
NL repository and put them on `PATH` (or in `~/.cargo/bin`):

```sh
git clone --recursive https://github.com/nl-lang/nl.git
cd nl
cargo build --release -p nl_lsp -p nlc
cp target/release/nl-lsp target/release/nlc ~/.cargo/bin/
```

Or point the extension at the binaries:

```json
{
  "nl.server.path": "/path/to/nl/target/release/nl-lsp",
  "nl.nlc.path": "/path/to/nl/target/release/nlc"
}
```

## Settings

| Setting | What it does |
|---|---|
| `nl.server.path` | The `nl-lsp` binary. Empty: `nl-lsp` on `PATH` or in `~/.cargo/bin`. |
| `nl.server.args` | Extra arguments for `nl-lsp`. |
| `nl.server.searchPath` | Directories of the import search path, as `nlc -I`. Relative to the workspace folder. |
| `nl.server.declarations` | `.d.nl` files or directories of them, as `nlc --decl`. Relative to the workspace folder. |
| `nl.server.env` | Environment variables for `nl-lsp` (`{ "RUST_BACKTRACE": "1" }`). |
| `nl.nlc.path` | The `nlc` binary, for formatting. Empty: `nlc` on `PATH` or in `~/.cargo/bin`. |
| `nl.format.enable` | Format with `nlc fmt` (default: on). |
| `nl.format.fix` | Pass `--fix` to `nlc fmt`. |
| `nl.trace.server` | Log the LSP traffic to the output channel. |

Commands: **NL: Restart Language Server** and **NL: Show Language Server
Output**. The status bar shows whether the server is running; click it for
the output.

For a Garry's Mod addon, declare the client profile's API with
`"nl.server.declarations": ["path/to/nl/decl/glua.d.nl"]`.

## Development

```sh
npm install
npm run build        # bundles src/extension.ts into dist/
npm test             # typecheck, grammar unit tests and snapshots
npm run package      # builds the .vsix
```

Press F5 in VS Code to run the extension in a development host.

The grammar is tested with [vscode-tmgrammar-test](https://github.com/PanAeon/vscode-tmgrammar-test):
`test/grammar/*.nl` hold inline scope assertions, and `test/snapshot/*.nl`
are tokenized in full and compared with their `.snap` files
(`npm run test:grammar:update` after a deliberate change).

## License

MIT
