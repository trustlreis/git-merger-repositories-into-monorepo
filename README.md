# Git Repository Merger - Monorepo Tool

This script automates the process of merging multiple Git repositories into a single **monorepo**, preserving commit history and tags for each repository. It clones each repository locally, prepares its structure by moving all contents into a subdirectory, and merges it into the monorepo repository.

---

## Features

- **Preserves Commit History**: Retains the full commit history of each repository.
- **Branch and Tag Synchronization**:
  - Merges key branches (`main`, `master`, `DEV`) into corresponding branches in the monorepo.
  - Additional branches are prefixed with their repository name.
  - Tags are preserved and prefixed with the repository name.
- **Repository Preparation**:
  - Moves each repository's files into a subdirectory named after the repository.
  - Excludes unnecessary files like `.gitattributes`, `.gitignore`, `.editorconfig` (optional).
- **Conflict Resolution**:
  - Automatically resolves merge conflicts using the `ours` strategy if necessary.
- **Push to Remote**: Pushes all branches and tags to a specified remote monorepo.

---

## Usage

```bash
./merge_repos.sh -f /path/to/input.csv -d /path/to/monorepo -r git@github.com:your-user/monorepo.git
```

### Options

- **`-f, --file`**: Path to the input CSV file listing repositories to be merged. (Required)
- **`-d, --directory`**: Path where the monorepo repository will be created. (Required)
- **`-r, --remote`**: Remote Git URL for the monorepo repository. (Required)
- **`--help`**: Display help information.

---

## Input CSV

The **input CSV file** (`input.csv`) lists the repositories to be merged. A template file (`input.csv_template`) is provided to help you create your own `input.csv`.

### Input CSV Format

The input CSV file should follow this format:

```csv
# YOU MUST LEFT A CR/LF AT THE END OF FILE
repo-name,git-url
```

### Example `input.csv`:

```csv
# YOU MUST LEFT A CR/LF AT THE END OF FILE
repo-name,git-url
pokemon-master-management,git@github.com:trustlreis/pokemon-master-management.git
mtls-client-server-poc,git@github.com:trustlreis/mtls-client-server-poc.git
```

#### Notes:
- **Blank Lines**: Ensure a blank line (CR/LF) is present at the end of the file.
- **Comments**: Lines starting with `#` are treated as comments and ignored.

### Example `input.csv_template`:

A template file (`input.csv_template`) is included in the repository:

```csv
# YOU MUST LEFT A CR/LF AT THE END OF FILE
repo-name,git-url
repo1,https://github.com/user/repo1.git
repo2,https://github.com/user/repo2.git
# Comments are allowed, and lines starting with '#' will be ignored
repo3,https://github.com/user/repo3.git
```

To use this template:

1. Copy `input.csv_template` to a new file:
   ```bash
   cp input.csv_template input.csv
   ```

2. Edit `input.csv` to list your repositories.

---

## How It Works

1. **Clone Repositories**:
   - Each repository is cloned into a temporary directory.

2. **Prepare Files**:
   - All files are moved into a subdirectory named after the repository.
   - Hidden files (e.g., `.gitignore`) are included.
   - Optional cleanup of unnecessary files like `.gitattributes`.

3. **Merge Into Monorepo**:
   - Key branches (`main`, `master`, `DEV`) are merged into the corresponding branches in the monorepo.
   - Other branches are prefixed with the repository name and merged into the monorepo.

4. **Push to Remote**:
   - Pushes all branches and tags to the specified monorepo remote URL.

---

## Commit History Notes

- **All commits appear merged in the monorepo commit history**:
  - The commit history of each repository is fully preserved after merging into the monorepo.

- **How commit history appears in tools**:
  - **In GitHub**:
    - When viewing a specific file, the most recent commit will show the monorepo preparation (e.g., the commit that moved the file into its subdirectory).
    - To view the full commit history for the file, click **"History"** or **"Browse History"** in the GitHub interface.
    - **Note**: The GitHub web interface does not consolidate the commit timeline. Instead, you'll see the preparation commit first, with legacy repository commits visible after browsing the file's history.
  - **In IDEs (IntelliJ, PyCharm, Eclipse, VS Code)**:
    - The commit history is consolidated as a single timeline, showing all commits for the artifact from both the monorepo and the original repository.
    - You can see the full historical context without needing to "browse" separately.

---

## Example Workflow

### Input CSV

```csv
# YOU MUST LEFT A CR/LF AT THE END OF FILE
repo-name,git-url
pokemon-master-management,git@github.com:trustlreis/pokemon-master-management.git
mtls-client-server-poc,git@github.com:trustlreis/mtls-client-server-poc.git
```

### Command

```bash
./merge_repos.sh -f /path/to/repositories.csv -d /path/to/monorepo -r git@github.com:your-user/monorepo.git
```

### Result

The script creates a monorepo with the following structure:

```plaintext
monorepo/
├── pokemon-master-management/
│   ├── src/
│   │   ├── file1.js
│   │   ├── file2.js
│   ├── .gitignore
│   └── README.md
├── mtls-client-server-poc/
│   ├── client/
│   ├── server/
│   ├── .gitignore
│   └── README.md
└── .git/
```

---

## Conflict Resolution

- The script automatically resolves merge conflicts during branch merging by applying the **`ours` strategy**, which prioritizes the monorepo's content over conflicting changes from individual repositories.

---

## Notes

- **Hidden Files**: The script ensures all hidden files (e.g., `.gitignore`, `.env`) are moved into the respective subdirectories.
- **Temporary Directories**: Temporary directories created for cloning repositories are deleted after merging.
- **Error Handling**: If any step fails (e.g., cloning, merging), the script will display an error message and terminate.
- **Commit History**:
  - All commits appear merged in the repository commit history.
  - **GitHub Web Interface**: Shows the preparation commit first but allows browsing legacy commits.
  - **IDEs**: Show a consolidated timeline.

---

## Requirements

- **Git**: Ensure Git is installed and available in the system's `PATH`.
- **Bash**: The script is designed to run in a Bash shell.
