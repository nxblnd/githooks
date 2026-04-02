# Git hook helper (in shell)

Simple git hooks helper, without dependencies[^1] and tracked inside your repository.

[^1]: Well, if you'll use manager script, it might be better if you have gum or fzf on your machine. But this is optional!

## How it works

This is git hooks helper + management tool for POSIX-compliant shells.

Hooks are placed into your repo with `git subtree` command, which is essentially merge of this repo into yours. No more submodule headaches, just regular files in repo (but still can be updated via fetch plus another merge).

Target directory is marked as containing hooks by setting `core.hooksPath` in git config.

Finally create symlink to `lib/hook.sh` with the name of git hook and create `%hook_name%.d` directory. All scripts inside it will run when the hook is called.

So, workflow is like this: git calles hook, say, `pre-commit`. This is the link to `lib/hook.sh`, which understands what hook it is, and in turn runs every script in `pre-commit.d/`.

## Installation

> [!NOTE]
> This is done once in lifetime (per repository)!  
> If you already have `.githooks` in your repo, skip to [post install](#post-install)

### One-line

Go into your repository and run this command:
```sh
curl -fsSL https://raw.githubusercontent.com/nxblnd/githooks/refs/heads/main/manager.sh | sh
```

### Manual

Go into your repository and run this command:
```sh
git subtree --prefix ".githooks" --squash add https://github.com/nxblnd/githooks.git main
```

### Post install

Use `.githooks/manager.sh` or run this to register hooks directory in your git config:
```sh
git config set core.hooksPath ".githooks"
```

## Usage

Run `.githooks/manager.sh` to add or remove hook symlinks and directories.

For manual hook management use this commands (while in root directory of repository):
```sh
# Replace %hook_name% with actual git hook name
ln -s .githooks/lib/hook.sh .githooks/%hook_name%  # e.g. pre-commit
mkdir .githooks/%hook_name%.d  # e.g. pre-commit.d
```

Now you can fill `.githooks/%hook_name%.d/` with whatever scripts you need! Don't forget to mark them executable. 

### Example

Create file `.githooks/pre-commit.d/lint.sh`:
```sh
#!/usr/bin/env sh

# Run linter before committing

npm run lint
```

And run
```sh
chmod +x .githooks/pre-commit.d/lint.sh
```
