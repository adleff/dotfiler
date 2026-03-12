```
      _       _    __ _ _
   __| | ___ | |_ / _(_) | ___ _ __
  / _` |/ _ \| __| |_| | |/ _ \ '__|
 | (_| | (_) | |_|  _| | |  __/ |
  \__,_|\___/ \__|_| |_|_|\___|_|

```

Your dotfiles are config. Config belongs in git.

dotfiler is a bash framework for versioning your dotfiles in a git repo
and symlinking them into place across any machine you work on. The goal
is a single source of truth for your environment — one `git clone` and
`bin/install.sh` away from feeling at home on any machine.


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

If you only use one platform, ignore the other overlay directory. If you
have a third context — a remote server, a work VM, a container — add
another overlay. The pattern scales to however many environments you manage.

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
