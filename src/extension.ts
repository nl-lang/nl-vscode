// The NL extension: starts `nl-lsp` for `.nl` files, and formats them
// with `nlc fmt`.

import * as cp from 'node:child_process';
import * as fs from 'node:fs';
import * as os from 'node:os';
import * as path from 'node:path';
import * as vscode from 'vscode';
import { LanguageClient, LanguageClientOptions, ServerOptions, State } from 'vscode-languageclient/node';

let client: LanguageClient | undefined;
let watcher: vscode.FileSystemWatcher | undefined;
let output: vscode.LogOutputChannel;
let status: vscode.StatusBarItem;

export async function activate(context: vscode.ExtensionContext): Promise<void> {
  output = vscode.window.createOutputChannel('NL Language Server', { log: true });
  status = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 50);
  status.command = 'nl.showOutput';
  context.subscriptions.push(
    output,
    status,
    vscode.commands.registerCommand('nl.restartServer', () => restartServer(context)),
    vscode.commands.registerCommand('nl.showOutput', () => output.show()),
    vscode.languages.registerDocumentFormattingEditProvider('nl', { provideDocumentFormattingEdits: format }),
    vscode.workspace.onDidChangeConfiguration((e) => {
      if (e.affectsConfiguration('nl.server')) {
        void restartServer(context);
      }
    }),
    vscode.window.onDidChangeActiveTextEditor(updateStatus),
    { dispose: () => void stopServer() },
  );
  await startServer(context);
}

export async function deactivate(): Promise<void> {
  await stopServer();
}

// ---- The language server ------------------------------------------------

async function startServer(context: vscode.ExtensionContext): Promise<void> {
  const config = vscode.workspace.getConfiguration('nl');
  const command = findBinary(config.get<string>('server.path') ?? '', 'nl-lsp');
  if (!command) {
    status.hide();
    void offerInstallHelp('nl-lsp', 'nl.server.path', 'cargo build --release -p nl_lsp');
    return;
  }
  const root = workspaceRoot();
  const resolve = (p: string): string => (root && !path.isAbsolute(p) ? path.join(root, p) : p);
  const initializationOptions = {
    searchPath: (config.get<string[]>('server.searchPath') ?? []).map(resolve),
    declarations: (config.get<string[]>('server.declarations') ?? []).map(resolve),
  };
  const serverOptions: ServerOptions = {
    command,
    args: config.get<string[]>('server.args') ?? [],
    options: {
      cwd: root,
      env: { ...process.env, ...(config.get<Record<string, string>>('server.env') ?? {}) },
    },
  };
  const clientOptions: LanguageClientOptions = {
    documentSelector: [{ language: 'nl' }],
    initializationOptions,
    outputChannel: output,
    synchronize: {
      // Declaration files and imported files change what a compile reports.
      fileEvents: (watcher = vscode.workspace.createFileSystemWatcher('**/*.nl')),
    },
  };
  client = new LanguageClient('nl', 'NL Language Server', serverOptions, clientOptions);
  client.onDidChangeState((e) => {
    if (e.newState === State.Running) {
      status.text = '$(check) NL';
      status.tooltip = `nl-lsp: ${command}`;
    } else if (e.newState === State.Starting) {
      status.text = '$(sync~spin) NL';
      status.tooltip = 'nl-lsp is starting';
    } else {
      status.text = '$(warning) NL';
      status.tooltip = 'nl-lsp is not running. Click for its output.';
    }
    updateStatus();
  });
  output.appendLine(`Starting ${command} ${serverOptions.args?.join(' ') ?? ''}`.trimEnd());
  try {
    await client.start();
  } catch (e) {
    output.appendLine(`nl-lsp failed to start: ${String(e)}`);
    void vscode.window.showErrorMessage(`The NL language server failed to start: ${String(e)}`, 'Show Output').then((pick) => {
      if (pick) {
        output.show();
      }
    });
  }
}

async function stopServer(): Promise<void> {
  const c = client;
  client = undefined;
  watcher?.dispose();
  watcher = undefined;
  if (c) {
    try {
      await c.stop();
    } catch {
      // The server was already gone.
    }
  }
}

async function restartServer(context: vscode.ExtensionContext): Promise<void> {
  await stopServer();
  await startServer(context);
}

function updateStatus(): void {
  const editor = vscode.window.activeTextEditor;
  if (editor?.document.languageId === 'nl' && client) {
    status.show();
  } else {
    status.hide();
  }
}

// ---- Formatting ---------------------------------------------------------

async function format(document: vscode.TextDocument): Promise<vscode.TextEdit[]> {
  const config = vscode.workspace.getConfiguration('nl');
  if (!config.get<boolean>('format.enable')) {
    return [];
  }
  const nlc = findBinary(config.get<string>('nlc.path') ?? '', 'nlc');
  if (!nlc) {
    void offerInstallHelp('nlc', 'nl.nlc.path', 'cargo build --release -p nlc');
    return [];
  }
  // `nlc fmt` reads files, not stdin. The copy keeps the document's
  // basename, since `.d.nl` files are formatted as declaration files.
  const dir = await fs.promises.mkdtemp(path.join(os.tmpdir(), 'nl-fmt-'));
  const file = path.join(dir, path.basename(document.fileName) || 'untitled.nl');
  try {
    await fs.promises.writeFile(file, document.getText(), 'utf8');
    const args = ['fmt', '--stdout'];
    if (config.get<boolean>('format.fix')) {
      args.push('--fix');
    }
    args.push(file);
    const result = await run(nlc, args, workspaceRoot());
    if (result.code !== 0) {
      // Diagnostics name the temporary copy; the server already shows them
      // under the document, so only say that formatting did not happen.
      const message = result.stderr.replaceAll(file, path.basename(file)).trim().split('\n')[0] ?? '';
      output.appendLine(`nlc fmt: ${result.stderr.trim()}`);
      void vscode.window.showWarningMessage(`NL: the file was not formatted. ${message}`);
      return [];
    }
    const formatted = result.stdout;
    if (formatted === document.getText()) {
      return [];
    }
    const whole = new vscode.Range(document.positionAt(0), document.positionAt(document.getText().length));
    return [vscode.TextEdit.replace(whole, formatted)];
  } finally {
    await fs.promises.rm(dir, { recursive: true, force: true });
  }
}

interface RunResult {
  code: number | null;
  stdout: string;
  stderr: string;
}

function run(command: string, args: string[], cwd: string | undefined): Promise<RunResult> {
  return new Promise((resolve, reject) => {
    cp.execFile(command, args, { cwd, maxBuffer: 64 << 20, encoding: 'utf8' }, (error, stdout, stderr) => {
      if (error && (error as NodeJS.ErrnoException).code === 'ENOENT') {
        reject(error);
        return;
      }
      const code = error && typeof (error as cp.ExecFileException).code === 'number' ? ((error as cp.ExecFileException).code as number) : error ? 1 : 0;
      resolve({ code, stdout, stderr });
    });
  });
}

// ---- Finding binaries ---------------------------------------------------

/// The binary named by a setting, or `name` on `PATH` or in `~/.cargo/bin`;
/// undefined when none is found.
function findBinary(setting: string, name: string): string | undefined {
  if (setting.trim()) {
    const p = expandHome(setting.trim());
    return isExecutable(p) ? p : undefined;
  }
  const exe = process.platform === 'win32' ? `${name}.exe` : name;
  const dirs = (process.env.PATH ?? '').split(path.delimiter).filter(Boolean);
  dirs.push(path.join(os.homedir(), '.cargo', 'bin'));
  for (const dir of dirs) {
    const candidate = path.join(dir, exe);
    if (isExecutable(candidate)) {
      return candidate;
    }
  }
  return undefined;
}

function isExecutable(p: string): boolean {
  try {
    fs.accessSync(p, fs.constants.X_OK);
    return fs.statSync(p).isFile();
  } catch {
    return false;
  }
}

function expandHome(p: string): string {
  return p.startsWith('~/') || p === '~' ? path.join(os.homedir(), p.slice(1)) : p;
}

function workspaceRoot(): string | undefined {
  return vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
}

const helpShown = new Set<string>();

async function offerInstallHelp(binary: string, setting: string, build: string): Promise<void> {
  if (helpShown.has(binary)) {
    return;
  }
  helpShown.add(binary);
  const pick = await vscode.window.showWarningMessage(
    `NL: \`${binary}\` was not found on PATH or in ~/.cargo/bin. Build it in the NL repository with \`${build}\`, then set \`${setting}\` or put it on PATH.`,
    'Open Settings',
    'Retry',
  );
  if (pick === 'Open Settings') {
    void vscode.commands.executeCommand('workbench.action.openSettings', setting);
  } else if (pick === 'Retry') {
    helpShown.delete(binary);
    void vscode.commands.executeCommand('nl.restartServer');
  }
}
