# Git Repository Merger into Monorepo

This script helps merge multiple Git repositories into a single unified monorepo, preserving commit history, branches, and tags. It supports custom branch and tag naming patterns to avoid conflicts.

## Features

- **Merge Multiple Repositories**: Combines repositories into a monorepo.
- **Preserve Commit History**: Ensures full commit history is retained for all branches and tags.
- **Branch Naming Pattern**: Uses structured patterns to avoid conflicts: 
  `feature/<repo>/<branch>`, `hotfix/<repo>/<branch>`, etc.
- **Tag Prefixing**: Tags are prefixed with `<repo>_` for uniqueness.
- **Custom Configuration**: Accepts paths to the input CSV, monorepo directory, and remote URL.

## Requirements

- Git installed on your system.
- A valid input CSV file listing repositories to merge.

## Usage

### Command-Line Options

```bash
./merge_repos.sh -f <path/to/input.csv> -d <path/to/monorepo> -r <remote_git_url>
```

- `-f, --file <path>`: Path to the input CSV file (required).
- `-d, --directory <path>`: Path where the monorepo will be created (required).
- `-r, --remote <url>`: Remote Git URL for the monorepo (required).
- `--help`: Display help documentation.

### Example

```bash
./merge_repos.sh -f /home/user/repositories.csv -d /home/user/monorepo -r git@github.com:user/monorepo.git
```

### Input CSV Format

The input CSV must have the following columns:

```csv
repo-name,git-url
repo1,https://github.com/user/repo1.git
repo2,https://github.com/user/repo2.git
# Comments are allowed, and lines starting with '#' will be ignored
repo3,https://github.com/user/repo3.git
```

- **`repo-name`**: A short, descriptive name for the repository.
- **`git-url`**: The repository’s Git URL.

### Output Structure

After merging, the monorepo will look like this:

```
monorepo/
├── repo1/
│   ├── files-from-repo1
├── repo2/
│   ├── files-from-repo2
├── .git/ (unified repository metadata)
```

Branches will be structured as:
```
feature/repo1/main
hotfix/repo2/fix-bug
uncategorized/repo3/legacy-branch
```

Tags will be structured as:
```
repo1_v1.0
repo2_patch-1
```

### Steps

1. **Prepare Input CSV**:
   Create an input CSV file listing repositories to be merged.

2. **Run the Script**:
   Use the `merge_repos.sh` script with the desired options:
   ```bash
   ./merge_repos.sh -f /path/to/repositories.csv -d /path/to/monorepo -r git@github.com:user/monorepo.git
   ```

3. **Verify the Monorepo**:
   - Check the structure of the monorepo directory.
   - Use `git log`, `git branch`, and `git tag` to confirm that commit history, branches, and tags are preserved.

4. **Push to Remote**:
   The script will automatically push the monorepo to the specified remote Git URL.

## Notes

- The script categorizes branches based on their prefixes (`feature/`, `hotfix/`, `bugfix/`). If no prefix is detected, branches are categorized under `uncategorized/`.
- Remotes for the original repositories are retained in the monorepo for debugging or later use. You can list them with:
  ```bash
  git remote -v
  ```
- **Preservation of Commit History**: The script ensures all commits, branches, and tags are intact in the monorepo.

## Troubleshooting

1. **Error: Input CSV Not Found**:
   - Ensure the input file exists at the specified path.

2. **Error: Failed to Fetch Repository**:
   - Verify that the Git URLs in the input CSV are correct and accessible.

3. **Branches Not Merging**:
   - Check for unrelated histories and ensure the `--allow-unrelated-histories` flag is used.

4. **Missing Commits**:
   - Use `git log` to verify commit history. Ensure that all branches were fetched and merged.

## Example Workflow

```bash
# Step 1: Prepare CSV
echo "repo-name,git-url" > repositories.csv
echo "repo1,https://github.com/user/repo1.git" >> repositories.csv
echo "repo2,https://github.com/user/repo2.git" >> repositories.csv

# Step 2: Run the Script
./merge_repos.sh -f repositories.csv -d /home/user/monorepo -r git@github.com:user/monorepo.git

# Step 3: Verify Output
cd /home/user/monorepo
git log --graph --oneline
git branch -a
git tag
```

## Contributing

Feel free to contribute improvements to this repository via pull requests.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.