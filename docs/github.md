# GitHub Setup

## SSH Commit Signing

This repo configures Git to sign commits and tags with SSH keys.

Shared config lives in `git/gitconfig`:

- `gpg.format = ssh`
- `include.path = ~/.gitconfig.local`

Per-machine config lives outside the repo in `~/.gitconfig.local`. Do not
commit private keys, public key inventories, or local Git config generated for a
specific host. Commit and tag signing are enabled there only after the local
signing key has been configured, so a missing `~/.gitconfig.local` does not
break every Git client.

To configure a new machine:

```sh
make install-git
make setup-git-signing
```

To repair a machine where Git signing suddenly starts failing:

```sh
make repair-git-signing
```

That is the local-only fix: it reinstalls `~/.gitconfig`, loads the private key
into the SSH agent, writes `~/.gitconfig.local`, and checks the result. It does
not try to register the key with GitHub.

By default this uses `~/.ssh/id_ed25519.pub` and labels the GitHub signing key
as `<hostname> git signing`. Override these when needed:

```sh
make setup-git-signing \
  GIT_SIGNING_KEY="$HOME/.ssh/id_work.pub" \
  GIT_SIGNING_KEY_TITLE="Personal Macbook"
```

The target:

- `user.signingkey` in `~/.gitconfig.local`
- `commit.gpgsign = true` in `~/.gitconfig.local`
- `tag.gpgSign = true` in `~/.gitconfig.local`
- `gpg.ssh.allowedSignersFile` in `~/.gitconfig.local`
- `~/.ssh/git_allowed_signers` for local `git log --show-signature` verification
- Adds the public key to GitHub as an SSH signing key when `gh` is available
- Loads the private key into the current SSH agent

If GitHub CLI lacks the required scope, refresh auth and rerun setup:

```sh
gh auth refresh -h github.com -s admin:ssh_signing_key
make setup-git-signing
```

On Linux and WSL, zsh starts or reuses a shared `ssh-agent` socket without
prompting during terminal startup. Run `make setup-git-signing` once per new
machine, and run `ssh-add ~/.ssh/id_ed25519` again only after the agent is reset
or WSL is restarted.

On macOS, SSH uses the system agent and Keychain. The setup target uses
`ssh-add --apple-use-keychain` so the passphrase can be restored by Keychain.
You should not need to run that before every commit; rerun `make
repair-git-signing` only if `ssh-add -l` reports no identities or Git signing
starts failing.

To check the current machine without changing configuration:

```sh
make check-git-signing
```

To verify with an actual temporary commit:

```sh
make verify-git-signing
```

GitHub verification is independent of the Git remote transport. HTTPS remotes
can still push signed commits; GitHub verifies the signature embedded in the
commit against the SSH signing key added to the account.

References:

- https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key
- https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account?tool=cli
- https://git-scm.com/docs/git-config
