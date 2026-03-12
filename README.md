```
      _       _    __ _ _
   __| | ___ | |_ / _(_) | ___ _ __
  / _` |/ _ \| __| |_| | |/ _ \ '__|
 | (_| | (_) | |_|  _| | |  __/ |
  \__,_|\___/ \__|_| |_|_|\___|_|

  your dotfiles. your machine. your rules.
```

A lightweight, OS-aware dotfile manager with no dependencies beyond bash.
Symlinks your config files into place, backs up anything in the way,
and gives you an audit tool to verify everything is wired correctly.

---

## How it works

```
dotfiler/
├── bin/
│   ├── install.sh      # symlinks everything into $HOME
│   └── check.sh        # verifies symlinks (--audit for full check)
├── home/               # common files, all platforms
│   ├── .gitconfig
│   ├── .aws/config
│   ├── .ssh/config
│   ├── .config/git/
│   │   ├── ignore
│   │   ├── personal.gitconfig
│   │   └── work.gitconfig
│   └── templates/
│       └── terraform-ignore
├── linux/home/         # Linux-only overrides (including WSL)
│   └── .bashrc
└── mac/home/           # macOS-only overrides
    └── .zshrc
```

Files in `home/` are symlinked for everyone.
Files in `linux/home/` or `mac/home/` overlay on top — same path wins.

---

## Getting started

```bash
git clone git@github.com:YOUR_USER/dotfiler.git ~/dotfiler
cd ~/dotfiler
chmod +x bin/install.sh bin/check.sh
bin/install.sh
```

That's it. Existing files are backed up as `filename.bak.YYYYMMDDHHMMSS` before being replaced.

---

## Verify your setup

Quick check:
```bash
bin/check.sh
```

Full audit (verifies every managed file is correctly symlinked):
```bash
bin/check.sh --audit
```

---

## Customize for yourself

Fork it, then drop your own files into the right place:

| What you want | Where to put it |
|---|---|
| Config for all platforms | `home/` |
| Linux / WSL specific | `linux/home/` |
| macOS specific | `mac/home/` |
| Your `.bashrc` | `linux/home/.bashrc` |
| Your `.zshrc` | `mac/home/.zshrc` |

The install script picks up whatever is there — no hardcoded file lists to maintain.

---

## Multiple git identities

The included `.gitconfig` uses `includeIf "gitdir:..."` to automatically
switch git identity based on which directory you're working in.

```
~/dev/personal/  →  personal.gitconfig  (personal email + SSH key)
~/dev/work/      →  work.gitconfig      (work email + SSH key)
```

Pair with the SSH config to use separate keys per identity — no manual `git config` per repo.

---

## AWS SSO

The example `~/.aws/config` shows how to configure an SSO-federated profile
via IAM Identity Center. Replace the placeholders and run:

```bash
aws configure sso
aws sso login --profile work-dev
```

No static keys needed.

---

## Included templates

`home/templates/terraform-ignore` — a solid `.gitignore` starting point for
Terraform projects. Copy it into a new repo:

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
