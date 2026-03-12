```
      _       _    __ _ _
   __| | ___ | |_ / _(_) | ___ _ __
  / _` |/ _ \| __| |_| | |/ _ \ '__|
 | (_| | (_) | |_|  _| | |  __/ |
  \__,_|\___/ \__|_| |_|_|\___|_|

  your dotfiles. your machine. your rules.
```

Your dotfiles are config. Config belongs in git.

dotfiler is a bash framework for versioning your dotfiles in a git repo
and symlinking them into place across any machine you work on. The goal
is a single source of truth for your environment — one `git clone` and
`bin/install.sh` away from feeling at home on any machine.

The symlink mechanism is the delivery layer. Git is the point.

---

## How it works

```
dotfiler/
├── bin/
│   ├── install.sh      # symlinks everything into $HOME
│   └── check.sh        # verifies symlinks (--audit for full check)
├── home/               # common files — symlinked on all platforms
│   ├── .gitconfig
│   ├── .aws/config
│   ├── .ssh/config
│   ├── .config/git/
│   │   ├── ignore
│   │   ├── personal.gitconfig
│   │   └── work.gitconfig
│   └── templates/
│       └── terraform-ignore
├── linux/home/         # Linux overrides — layered on top of home/
│   └── .bashrc
└── mac/home/           # macOS overrides — layered on top of home/
    └── .zshrc
```

Files in `home/` are symlinked on every platform. Files in `linux/home/`
or `mac/home/` are layered on top — same relative path wins.

### Why overlays?

Not everything ports cleanly across operating systems. Your shell rc file,
`PATH` setup, and package manager hooks look different on Linux vs macOS
even if your overall philosophy is the same. Rather than stuffing your
common files full of `if [[ "$(uname)" == ... ]]` conditionals, overlays
let each platform have its own version of a file while everything else
stays shared.

If you only use one platform, ignore the other overlay directory entirely.

### Adding your own overlay

The `linux` and `mac` overlays are defined in `bin/install.sh` — they're
not magic, just a detection check and a `link_tree` call. Adding a new
context (a remote server, a work VM, a container) means adding a directory
and a few lines to the script.

For example, to add a `server` overlay for a headless Linux environment
where you want a different `.bashrc` than your desktop Linux setup:

**1. Create the overlay directory and add your files:**
```bash
mkdir -p server/home
# add any files that should differ on servers
cp linux/home/.bashrc server/home/.bashrc
# edit server/home/.bashrc to remove desktop-only stuff
```

**2. Add detection logic to `bin/install.sh`:**
```bash
# near the top with the other detection flags
is_server=false
if [[ -f /etc/server-marker ]]; then   # use whatever makes sense for your setup
  is_server=true
fi

# near the bottom with the other link_tree calls
if $is_server; then
  link_tree "$REPO_DIR/server/home"
fi
```

**3. Add the same block to `bin/check.sh`** so the audit knows about it.

That's it — the `link_tree` function handles the rest. Files in your new
overlay directory will be symlinked on top of `home/`, same as `linux` and `mac`.

---

## Getting started

```bash
git clone git@github.com:adleff/dotfiler.git ~/dotfiler
cd ~/dotfiler
chmod +x bin/install.sh bin/check.sh
bin/install.sh
```

Existing files are backed up as `filename.bak.YYYYMMDDHHMMSS` before
being replaced — nothing is ever deleted.

---

## Verify your setup

Quick check:
```bash
bin/check.sh
```

Full audit — verifies every managed file is correctly symlinked:
```bash
bin/check.sh --audit
```

---

## Customize for yourself

Fork it, then drop your own files into the right place:

| What you want | Where to put it |
|---|---|
| Config for all platforms | `home/` |
| Linux specific | `linux/home/` |
| macOS specific | `mac/home/` |
| Your `.bashrc` | `linux/home/.bashrc` |
| Your `.zshrc` | `mac/home/.zshrc` |

The install script picks up whatever files are present — no hardcoded
lists to maintain. Add a file, re-run `install.sh`, done.

---

## Multiple git identities

The included `.gitconfig` uses `includeIf "gitdir:..."` to automatically
switch git identity based on which directory you're working in.

```
~/dev/personal/  →  personal.gitconfig  (personal email + SSH key)
~/dev/work/      →  work.gitconfig      (work email + SSH key)
```

Pair with the SSH config to use a separate key per identity — no manual
`git config` per repo, no accidentally committing with the wrong email.

---

## AWS SSO

The example `~/.aws/config` shows how to configure an SSO-federated profile
via IAM Identity Center — no static keys required.

```bash
aws configure sso
aws sso login --profile work-dev
```

---

## Included templates

`home/templates/terraform-ignore` — a solid `.gitignore` starting point
for Terraform projects. Since dotfiler symlinks it to `~/templates/`,
it's always one copy away:

```bash
cp ~/templates/terraform-ignore ~/dev/work/my-new-repo/.gitignore
```

---

## Philosophy

- **No magic.** Just bash and symlinks.
- **Non-destructive.** Existing files are always backed up, never deleted.
- **Auditable.** `check.sh --audit` tells you exactly what's wired and what isn't.
- **Fork-friendly.** The framework ships without personal config — add your own.

---

## License

MIT
