# Table of Contents
1. [What is Git](#what-is-git)
	1. [Primitive objects in Git](#primitive-objects-in-git)
	2. [How Git tracks changes](#how-git-tracks-changes)
	3. [Definitions](#definitions)
	4. [Pathspec syntax](#pathspec-syntax)
	5. [Resolution strategies](#resolution-strategies)
	6. [Revision syntax](#revision-syntax)
2. [Git commands](#git-commands)
	1. [Initialize Setup](#initialize-setup)
	2. [Inspect Repository](#inspect-repository)
	3. [Prepare Working Tree and Commits](#prepare-working-tree-and-commits)
	4. [Track Histories](#track-histories)
	5. [Combine Histories](#combine-histories)
	6. [Remote Repository](#remote-repository)
	7. [Plumbing commands](#plumbing-commands)
3. [Common Scenarios](#common-scenarios)


# What is Git
- Git = File system + Versioning + Branching & merging
- Git is a persistent map where the keys are SHA1 hashes and they reference primitive objects

## Primitive objects in Git
- Blob: file contents / raw bytes of a file
- Tree (folder): contains
	- References to file blobs and metadata like filename, permissions, etc.
	- References to subtrees (subfolders): Emulates folder/directory structure [*Implementation of file system*]
- Commit: contains
	- Commit message, time of commit, author name & email
	- Reference to the root tree: A snapshot of the root directory at the time of commit
	- References to parent commits: A way to trace the previous commits / history [*Implementation of versioning*]
		- The initial commit has no parent commits
		- Non-merge commits have exactly 1 parent commit
		- Merge commits have multiple parent commits [*Implementation of branching & merging*]

<p align="center">
	<img src="./GIT_diagram.PNG"/ width=75%> <br>
	<b>Git object & commit diagram</b>
	<!-- TODO: branching and merging diagram -->
</p>

## How Git tracks changes
- When the changes of some file is tracked:
	1. It's blob conents changes
	2. The blob's reference changes
	3. It's tree contents changes (to reference the new blob)
	4. The tree's reference changes
	5. The tree's supertrees has to update as well (to reference the new tree) until the root tree
- A new commit has to be made to track the reference to the new root tree
- Important corollary: Simple changes to an existing commit will cause the history to diverge
	- Simply changing the commit message (while keeping all the files & versions exactly the same) would change the commit hash and subsequent commit hashes causing a divergence
	- This merging / pulling from a similar divergent branch would result in duplicated commits
</details>

## Definitions
- Named reference: A name associated with an actual reference (SHA1 hash)
- Branch: A named reference to some commit
	- New commits to a branch will automatically update its referenced commit
- Tag: A named reference to some commit, but no auto updates
	- Useful for saving unfinished work or creating backups
- HEAD: A named reference to the latest commit in the current branch
- Remote: A named reference to remote repository (default name: origin)
- Remote-tracking branch: A local copy of a branch in the remote (default name: origin/<BRANCH_NAME>)
- Remote branch: The branch that exists in the remote (default name: origin <BRANCH_NAME>)
- Working tree: The local directory of the repository / the folder in your hard drive
- Index / Staging area: Contains all the changes to be tracked by a new commit
- Upstream: Where to pull from
- Downstream: Where to push to
- Reference logs (reflogs) record when references were updated in the local repository
	- This includes the previous states of HEAD - good for reverting bad resets, checkouts, merges
- `...`: Denotes a repeatable argument (space separated) 
- Revisions: Are ways of specifying commits
- Pathspecs: Are ways of specifiying paths that to be passed to certain Git commands
- Resolution strategy: Rule that automatically resolves conflicts
- gitignore: Specifies intentionally untracked files to ignore
- detached HEAD: Occurs whenever HEAD does not refer to a branch
- patch: Stored file diffs

## Pathspec syntax
- Pathspecs are usually preceded by two dashes: `<GIT_COMMAND> -- <PATHSPEC>`
- Pathspecs are specified using any of following:
	- Individual file path/s: `<FILE_i>...`
	- File paths in the glob pattern: `lib/*.js`
- Examples:
	- `git add -- file1.txt file2.txt file3.txt`
	- `git rm -- file*.txt`

## Resolution strategies
- [Resolution strategies](https://git-scm.com/docs/merge-strategies) are specified using any of following:
	- `ours`: Forces conflicting hunks to be auto-resolved cleanly by favoring our version
	- `theirs`: Opposite of ours

## Revision syntax
- [Revisions](https://git-scm.com/docs/gitrevisions) are specified using any of following:
	- Commit hash: `<COMMIT_HASH>`
	- Named reference (REF_NAME) with an optional suffix (REF_NAME_SUFFIX):
		- Reference name without suffix: `<REF_NAME>`
		- Reference name with suffix: `<REF_NAME><REF_NAME_SUFFIX>`
		- Reference name suffixes (REF_NAME_SUFFIX):
			- From time: `@{'<NUMBER> <seconds|minutes|hours|days|weeks|months> ago'}`
			- From upstream: `@{upstream}`
			- From downstream: `@{push}`
	- Revisions from other revisions (REV) with an optional suffix (REV_SUFFIX):
		- Revision without suffix: `<REV>`
		- Revision with suffix: `<REV><REV_SUFFIX>`
		- Revision suffixes (REV_SUFFIX):
			- From N-th parent: `^{N}`
			- From N-th generation ancestor (takes the first parents only): `~{N}` 
	- Latest revision where the substring (SUB) occurs in the commit message: `:/<SUB>`
	- Latest revision where the substring (SUB) occurs in the commit message that is also reachable by (REV): `<REV>^{/<SUB>}`
- Examples:
	- The current head: `HEAD`
	- The commit on my-branch 10 minutes ago: `my-branch@{'10 minutes ago'}`
	- The commit on the master branch in the remote: `master@{upstream}`
	- The 2nd parent of the 1st parent of my-tag: `my-tag^1^2`
	- The 3rd generation ancestor of c4470d0d5: `c4470d0d5~3` or `c4470d0d5^1^1^1`
	- The commits in HEAD that are not in master: `master..HEAD`

## Revision range syntax
asd
	- Revision ranges from other revisions (REV_RANGE):
		- All commits from REV_2 that are not in REV_1: `<REV_1>..<REV_2>`
		- All commits from REV_2 that are not in the lastest common ancestor (merge-base) of REV_1 and REV_2: `<REV_1>...<REV_2>`

# Git commands
A non-exhaustive list of Git commands and command options. See [Common Scenarios](#common-scenarios) for sample uses of these commands.
All commands take the option `-h` and output appropriate help docs.

## Initialize Setup
- [init](https://git-scm.com/docs/git-init.html): Create an empty Git repository or reinitialize an existing one
- [clone](https://git-scm.com/docs/git-clone.html): Clone a repository into a new directory
	- `git clone <URL>`
- [config](https://git-scm.com/docs/git-config.html): Get and set repository or global options
	- `git config <OPTIONS>`
	- Options:
		- `--list`: List all variables set in config file along with their values
		- `--global <KEY> <VALUE>`: Write to global config file rather than the repository config file
			- `--global user.name '<NAME>'`
			- `--global user.email '<EMAIL>'`
			- `--global core.editor 'notepad'`: Sets the text editor used by Git from vim to notepad.
			- `git config --global merge.tool <TOOL_NAME>`
			- `git config --global mergetool.<TOOL_NAME>.path "<TOOL_PATH>"`
				- [meld](http://meldmerge.org/) is a popular merge tool
				- `git config --global merge.tool meld`
				- `git config --global mergetool.meld.path "C:\Program Files (x86)\Meld\Meld.exe"`

## Inspect Repository
- [bisect](https://git-scm.com/docs/git-bisect.html): Use binary search to find the commit that introduced a bug
- [blame](https://git-scm.com/docs/git-blame.html): Show what revision and author last modified each line of a file
	- `git blame <FILE>`
	- `git blame -- <PATHSPEC>`
- [cat-file](https://git-scm.com/docs/git-cat-file): Provide content or type and size information for repository objects
	- `git cat-file -p HEAD`: Will show the contents of the HEAD commit file
- [cherry](https://git-scm.com/docs/git-cherry.html): Find commits yet to be applied to upstream
- [diff](https://git-scm.com/docs/git-diff.html): Show changes between commits, commit and working tree, etc
	- `git diff <OPTIONS> <REV_1>..<REV_2>`
	- `git diff <OPTIONS> <REV_1> <REV_2>`: Abbreviation for `<REV_1>..<REV_2>`
	- `git diff <OPTIONS> <REV_1> <REV_2> -- <PATHSPEC>`
	- If REV_2 is not given, then REV_2 defaults to HEAD
	- Options:
		- `--stat`: Display the files changed and diffstats
		- `--cached`: Diff starting from the index, i.e. REV_1 will be the index
		- `--word-diff`: Show a word diff
- [diff-tree](https://git-scm.com/docs/git-diff-tree.html): Compares the content and mode of blobs found via two tree objects
- [grep](https://git-scm.com/docs/git-grep): Print lines matching a pattern
	- `git grep <OPTIONS>`
	- `git grep <OPTIONS> -- <PATHSPEC>`
	- Options:
		- `--cached`: Grep against the index
		- `-E`: Treat patterns as extended regex
		- `-e <PATTERN>`: Specify a pattern
		- `--not -e <PATTERN>`: Specify a new pattern by NOT-ing PATTERN
		- `\( -e <PATTERN_1> --or -e <PATTERN_2> \)`: Specify a new pattern by OR-ing PATTERN_1 and PATTERN_2
		- `\( -e <PATTERN_1> --and -e <PATTERN_2> \)`: Specify a new pattern by AND-ing PATTERN_1 and PATTERN_2
- [help](https://git-scm.com/docs/git-help.html): Display help information about Git
- [log](https://git-scm.com/docs/git-log.html): Show commit logs
	- `git log`
	- `git log <REV>`
	- `git log <REV_RANGE>`
	- Options:
		- `--oneline`: Shows abbreviated single line version of commit logs
- [ls-files](https://git-scm.com/docs/git-ls-files.html): Show information about files in the index and the working tree
- [ls-tree](https://git-scm.com/docs/git-ls-tree.html): List the contents of a tree object
- [reflog](https://git-scm.com/docs/git-reflog.html): Manage reflog information
	- `git reflog`
	- `git reflog <OPTIONS>`
	- Options:
		- `--all`: Process the reflogs of all references including the individual steps within rebase/merge
- [show](https://git-scm.com/docs/git-show.html): Show various types of objects
- [show-branch](https://git-scm.com/docs/git-show-branch.html): Show branches and their commits
- [show-ref](https://git-scm.com/docs/git-show-ref.html): List references in a local repository
- [status](https://git-scm.com/docs/git-status.html): Show the working tree status

## Prepare Working Tree and Commits
- [add](https://git-scm.com/docs/git-add.html): Add file contents to the index
	- `git add <OPTIONS> <FILE>`
	- `git add <OPTIONS> -- <PATHSPEC>`
	- `git add <OPTIONS> .`: Stage all files in the current directory
	- Options:
		- `<-f|--force>`: Allow the adding of otherwise ignored files
- [apply](https://git-scm.com/docs/git-apply.html): Apply a patch to files and/or to the index
- [clean](https://git-scm.com/docs/git-clean.html): Remove untracked files from the working tree
- [rm](https://git-scm.com/docs/git-rm.html): Remove files from the working tree and from the index
	- `git rm <OPTIONS> <FILE>`
	- `git rm <OPTIONS> -- <PATHSPEC>`
	- `git rm <OPTIONS> <FOLDER>`
	- Options:
		- `-r`: Allows recursive removal when passing a folder
		- `--cached`: Remove file from the index but keep it in the working tree
- [checkout](https://git-scm.com/docs/git-checkout.html): Restore working tree files
	- `git checkout <REV> -- <PATHSPEC>`
- [commit](https://git-scm.com/docs/git-commit.html): Record changes to the repository
	- `git commit`: Create a new commit via text editor
	- `git commit <OPTIONS>`
	- Options:
		- `<-a|--amend>`: Include the indexed changes to the latest commit
		- `-m <MESSAGE>`: Specifies the commit message
		- `--fixup=<REV>`: Creates a commit that is fixup-able to the specified revision (default behaviour: you can only create fixup commits applicable to the HEAD)
- [reset](https://git-scm.com/docs/git-reset.html): Reset current HEAD to the specified state
	- `git reset <MODE> <REV>`
	- Modes:
		- `--hard`: Reset the index and working tree
		- `--soft`: Keep the index and working tree
		- `--mixed`: Reset the index and keep the working tree (default)
- [rebase](https://git-scm.com/docs/git-rebase.html): Reapply commits on top of another base tip
	- `git rebase <OPTIONS> <REV_i>...`
	- Options:
		- `<-i|--interactive>`: Lets the user edit the base tip before reapplying commits
			- `<p|pick>`: use commit
			- `<r|reword>`: use commit, but edit the commit message
			- `<e|edit>`: use commit, but stop for amending
			- `<s|squash>`: use commit, but meld into previous commit
			- `<f|fixup>`: like "squash", but discard this commit's log message
			- `<d|drop>`: remove commit
		- `--autosquash`: Automatically fixups commits that are tagged as fixup 
- [revert](https://git-scm.com/docs/git-revert.html): Create a new commit that reverts existing commits
- [stash](https://git-scm.com/docs/git-stash.html): Stash the changes in a dirty working directory away
		- `git stash`
		- `git stash pop`: Applies the latest stashed changes on the current working tree

## Track Histories
- [branch](https://git-scm.com/docs/git-branch.html): List, create, or delete branches
	- `git branch <OPTIONS>`
	- Options:
		- `--list`: List branches
		- `-d`: Delete branch
- [checkout](https://git-scm.com/docs/git-checkout.html): Switch branches or restore working tree files
	- `git checkout <OPTIONS> <BRANCH_NAME>`: Switch branches
	- Options:
		- `-f`: Proceed even if the index or the working tree differs from HEAD and throw away local changes
		- `-b`: Create a new branch then switch
- [tag](https://git-scm.com/docs/git-tag.html): Create, list, delete or verify a tag object
	- `git tag <TAG_NAME>`: Creates a new tag
	- `git tag <OPTIONS> <TAG_NAME>`
	- Options:
		- `-d`: Delete a tag
		- `-l`: List all tags

## Combine Histories
- [cherry-pick](https://git-scm.com/docs/git-cherry-pick.html): Apply the changes introduced by some existing commits and create a new commit
	- `git cherry-pick <OPTIONS> <REV_i>...`: Apply diffs from the specified revisions
	- `git cherry-pick --<continue|quit|abort>`
	- Options:
		- `--no-commit`: Apply the changes but keep them in the index
- [merge](https://git-scm.com/docs/git-merge.html): Integrate the changes from two or more development histories together
	- `git merge <OPTIONS> <REV_i>...`
	- `git merge --<abort|continue>`
	- Options:
		- `--strategy=<RESOLUTION_STRATEGY>`
- [merge-base](https://git-scm.com/docs/git-merge-base.html): Find as good common ancestors as possible for a merge
- [rebase](https://git-scm.com/docs/git-rebase.html): Reapply commits on top of another base tip
	- `git rebase <OPTIONS> <REV_i>...`
		- `--strategy=<RESOLUTION_STRATEGY>`

## Remote Repository
- [fetch](https://git-scm.com/docs/git-fetch.html): Download objects and refs from another repository then update the remote-tracking branch
	- `git fetch`: Fetch current branch
	- `git fetch <OPTIONS>`
	- Options:
		- `--all`: Fetch all remotes
- [pull](https://git-scm.com/docs/git-pull.html): Fetch from and integrate with another repository or a local branch
	- `git pull`: An abbreviation for `git fetch` then `git merge origin/<CURRENT_BRANCH>`
	- `git pull <OPTIONS> <REMOTE> <BRANCH_NAME>`
	- Options:
		- `-f`: Forcefully pull when existing commits are overridden (default behaviour: Git only accepts commits that are on top of existing commits)
		- `--rebase`: An abbreviation for `git fetch` then `git rebase` rather than `git merge`
		- `--strategy=<RESOLUTION_STRATEGY>`
- [push](https://git-scm.com/docs/git-push.html): Update remote refs along with associated objects
	- `git push <OPTIONS> <REMOTE> <BRANCH_NAME>`
	- Options:
		- `-f`: Forcefully push when existing commits in the remote are overridden (default behaviour: Git only accepts commits that are on top of existing commits)
		- `-d`: Refs are deleted from the remote repository
		- `--set-upstream`: Sets the default upstream
- [remote](https://git-scm.com/docs/git-remote.html): Manage set of tracked repositories
	- `git remote <OPTIONS>`
	- `git remote add <REMOTE_NAME> <REMOTE_URL>`
	- `git remote rename <OLD_REMOTE_NAME> <NEW_REMOTE_NAME>`
	- `git remote rm <REMOTE_NAME>`
	- Options:
		- `-v`: Shows both the name and url

## Miscellaneous commands
- [cat-file](https://git-scm.com/docs/git-cat-file): Provide content or type and size information for repository objects
- [difftool](https://git-scm.com/docs/git-difftool): Show changes using common diff tools
	- `git difftool <REV> --tool=<TOOL_NAME>`
- [gc](https://git-scm.com/docs/git-gc.html): Cleanup unnecessary files and optimize the local repository
- [gui](https://git-scm.com/docs/git-gui.html): A portable graphical interface to Git
- [mergetool](https://git-scm.com/docs/git-mergetool): Run merge conflict resolution tools to resolve merge conflicts
	- `git mergetool --tool=<TOOL_NAME>`
- [prune](https://git-scm.com/docs/git-prune.html): Prune all unreachable objects from the object database
- [rev-parse](https://git-scm.com/docs/git-rev-parse): Pick out and massage parameters


# Common Scenarios
- Check the summary staged changes:
	- `git diff --cached --stat`
- Restore previous version of certain files:
	- `git checkout <REV> -- <PATHSPEC>`
- Edit commit history:
	- `git rebase -i HEAD~<N>`
- Reset index:
	- `git rm --cached -- <PATHSPEC>`: Removes changes for files
	- `git checkout HEAD -- <PATHSPEC>`: Resets changed file (including deleted files)
- Reset changes: 
	- `git reset --hard <REV>`: Use if changes are not longer relevant
	- `git reset --soft <REV>`: Use if changes are usable for the next commit
- Remove untracked files:
	- `git clean -dfx`: (Dangerous)
- Find and display merge base ancestor hash and contents:
	- `git merge-base HEAD origin/master | xargs -I{} sh -c "printf 'Merge base: '{}'\n\n' && git cat-file -p {}"`
- Patch file operations:
	- Creating a patch: `git diff <REV_1> <REV_2> > ~/my_changes.patch`
	- Applying a patch: `git apply ~/my_changes.patch`
- Stage changes from another commit:
	- `git cherry-pick <REV> --no-commit`: Useful for picking up changes from old branches or dropped features
- Filter blame:
	- `git ls-tree -r origin/master --name-only | xargs -I{} git blame {} | grep <LINE_FILTER>`
	- Example:
		- `git ls-tree -r origin/master --name-only | xargs -I{} git blame {} | grep '2018-11-'`
		- `git ls-tree -r origin/master --name-only`: Display all the filenames in the tree of origin/master, then pipe out
		- `xargs -I{} git blame {}`: Take the piped filenames and passes it to git blame, then pipe out
		- `grep '2018-11-'`: Take the piped blame and keep only the rows that contain "2018-11-"
- Using a second local repository: for multi-tasking
	- `git remote add myotherrepo <PATH>/<REPO_DIR>`
- Finding a pattern within the tracked files:
	- `git grep <PATTERN>`
- Finding the commits in HEAD that are behind from latest master:
	- `git fetch --all && git log --oneline HEAD...origin/master`: pipe to `wc -l` to count output lines
- Search for a branch:
	- `git branch --list --all | grep <QUERY>`
- Search in tracked files:
	- `git ls-files --others --exclude-standard | grep <QUERY>`
- More detailed single line logs:
	- `git log --date=short --pretty=format:"%ad:%Cgreen%an:%Cred%d:%Creset%s"`
- XM life hacks
	- `git log --date=short --pretty=format:"%ad:%Cgreen%an:%Cred%d:%Creset%s" --reverse --all --since="5 days ago" --author=Guzman`


# Git AHK script
AutoHotKey is a tool that allows users to trigger OS-level macros using specified triggers.
1. Download both the <a href="./../tools/AutoHotkeyU32_1.1.30.01.exe">AHK executable</a> and the <a href="./GitMaster.ahk">AHK script</a>
2. Open the AHK script using the AHK executable ("drag and drop" or "run as")


- Example usage (where [] is the current caret position) :
	- ";rg": Runs git bash
	- ";gcd": Types `cd ~/git/coleman.ui/`
	- ";gfa": Types `git fetch --all`
	- ";gl": Types `git log --date=short --pretty=format:"%ad:%Cgreen%an:%Cred%d:%Creset%s"`
	- ";grpl": Types `git pull origin master --rebase`
	- ";gg": Types `git grep -n --break --heading -E "[]"`
	- ";gri": Types `git rebase -i --autosquash HEAD~`
	- ";gsri": Types `git stash && git rebase -i --autosquash HEAD~[] && git stash pop`


# References: 
- https://git-scm.com/docs
<!-- TEMP DUMP
git ls-files --others --exclude-standard | grep .java$
git add -u 
-->