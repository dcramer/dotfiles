# GitHub Setup

## SSH Commit Signing

This repo configures Git to sign commits and tags with SSH keys.

Shared config lives in `git/gitconfig`:

- `gpg.format = ssh`
- `commit.gpgsign = true`
- `tag.gpgSign = true`
- `include.path = ~/.gitconfig.local`

Per-machine config lives outside the repo in `~/.gitconfig.local`. Do not
commit private keys, public key inventories, or local Git config generated for a
specific host.

To configure a new machine:

```sh
make install-git
make configure-git-signing
```

By default this uses `~/.ssh/id_ed25519.pub` and labels the GitHub signing key
as `Work Macbook`. Override these when needed:

```sh
make configure-git-signing \
  GIT_SIGNING_KEY="$HOME/.ssh/id_work.pub" \
  GIT_SIGNING_KEY_TITLE="Personal Macbook"
```

The target writes:

- `user.signingkey` in `~/.gitconfig.local`
- `gpg.ssh.allowedSignersFile` in `~/.gitconfig.local`
- `~/.ssh/git_allowed_signers` for local `git log --show-signature` verification

After local setup, add the public key to GitHub as an SSH signing key:

```sh
gh ssh-key add ~/.ssh/id_ed25519.pub --type signing --title "Work Macbook"
```

If GitHub CLI lacks the required scope:

```sh
gh auth refresh -h github.com -s admin:ssh_signing_key
```

Then rerun the `gh ssh-key add` command.

To verify locally:

```sh
git commit --allow-empty -m "test signed commit"
git log --show-signature -1
```

GitHub verification is independent of the Git remote transport. HTTPS remotes
can still push signed commits; GitHub verifies the signature embedded in the
commit against the SSH signing key added to the account.

References:

- https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key
- https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account?tool=cli
- https://git-scm.com/docs/git-config
