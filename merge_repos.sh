#!/bin/bash

################################################################################
# merge_repos.sh
#
# Description:
#   This script merges multiple Git repositories into a unified monorepo.
#   It clones each repository, prepares its structure, and merges it into the
#   monorepo repository.
#
# Usage:
#   ./merge_repos.sh -f /path/to/input.csv -d /path/to/monorepo -r git@github.com:your-user/monorepo.git
#
# Options:
#   -f, --file <path>      Path to the input CSV file (required).
#   -d, --directory <path> Path to create the monorepo (required).
#   -r, --remote <url>     Remote Git URL for the monorepo (required).
#
# Input CSV Format:
#   The CSV file must contain the following columns:
#     repo-name,git-url
################################################################################

# Functions
function print_help {
  sed -n '/^################################################################################/,/^################################################################################/p' "$0"
  exit 0
}

function error_exit {
  echo "Error: $1"
  exit 1
}

# Parse Arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -f|--file) INPUT_CSV="$2"; shift ;;
    -d|--directory) MONOREPO_DIR="$2"; shift ;;
    -r|--remote) REMOTE_URL="$2"; shift ;;
    --help) print_help ;;
    *) error_exit "Unknown parameter passed: $1" ;;
  esac
  shift
done

# Validate Arguments
[[ -z "$INPUT_CSV" ]] && error_exit "Input CSV file is required. Use -f to specify."
[[ -z "$MONOREPO_DIR" ]] && error_exit "Monorepo directory is required. Use -d to specify."
[[ -z "$REMOTE_URL" ]] && error_exit "Remote URL is required. Use -r to specify."

# Resolve the absolute path of INPUT_CSV
if [[ ! "$INPUT_CSV" =~ ^/ ]]; then
  INPUT_CSV="$(cd "$(dirname "$INPUT_CSV")" && pwd)/$(basename "$INPUT_CSV")"
fi
[[ ! -f "$INPUT_CSV" ]] && error_exit "Input CSV file not found: $INPUT_CSV."

# Create Monorepo Directory
mkdir -p "$MONOREPO_DIR" || error_exit "Failed to create directory: $MONOREPO_DIR."
pushd "$MONOREPO_DIR" > /dev/null || error_exit "Failed to navigate to directory: $MONOREPO_DIR."

# Initialize Git Repository
if [ ! -d ".git" ]; then
  echo "Initializing monorepo Git repository..."
  git init || error_exit "Failed to initialize Git repository."
  touch .gitkeep
  git add .gitkeep
  git commit -m "Initial commit for monorepo"
fi

popd > /dev/null

# Clone and Prepare Each Repository
while IFS=, read -r REPO_NAME GIT_URL; do
  # Skip header row and comments
  if [[ "$REPO_NAME" == "repo-name" && "$GIT_URL" == "git-url" ]] || [[ "$REPO_NAME" =~ ^# ]]; then
    continue
  fi

  echo "Processing repository: $REPO_NAME from $GIT_URL"

  # Clone Repository
  CLONE_DIR="${MONOREPO_DIR}_temp_${REPO_NAME}"
  git clone "$GIT_URL" "$CLONE_DIR" || error_exit "Failed to clone $GIT_URL."

  pushd "$CLONE_DIR" > /dev/null || error_exit "Failed to navigate to cloned directory: $CLONE_DIR."

  # Checkout and Pull Latest Branch
  git checkout master || git checkout main || error_exit "Failed to checkout master or main branch."
  git pull origin || error_exit "Failed to pull latest changes for $REPO_NAME."

  # Create a Monorepo Preparation Branch
  git checkout -b prepare_monorepo || error_exit "Failed to create preparation branch."

  # Move Files into Subdirectory
  mkdir -p "$REPO_NAME"
  shopt -s dotglob
  for item in *; do
    if [[ "$item" != "$REPO_NAME" && "$item" != ".git" ]]; then
      git mv "$item" "$REPO_NAME/" || error_exit "Failed to move $item into subdirectory for $REPO_NAME."
    fi
  done
  shopt -u dotglob

  # Remove Unnecessary Files (optional)
  git rm -f --ignore-unmatch .gitattributes .gitignore .editorconfig || true

  # Commit Changes
  git commit -m "Preparing $REPO_NAME for monorepo merge" || error_exit "Failed to commit changes for $REPO_NAME."

  popd > /dev/null

  # Merge into Monorepo
  pushd "$MONOREPO_DIR" > /dev/null || error_exit "Failed to navigate to monorepo directory."
  git remote add temp_"$REPO_NAME" "$CLONE_DIR"
  git fetch temp_"$REPO_NAME" || error_exit "Failed to fetch $REPO_NAME."
  git merge --allow-unrelated-histories temp_"$REPO_NAME"/prepare_monorepo -m "Merge $REPO_NAME into monorepo." || {
    echo "Conflicts detected while merging $REPO_NAME. Applying 'ours' strategy..."
    git merge --strategy=ours temp_"$REPO_NAME"/prepare_monorepo -m "Resolve conflicts for $REPO_NAME using 'ours' strategy."
  }
  git remote remove temp_"$REPO_NAME"
  popd > /dev/null

  # Cleanup Temporary Directory
  rm -rf "$CLONE_DIR"
done < "$INPUT_CSV"

# Push Changes to Remote
pushd "$MONOREPO_DIR" > /dev/null || error_exit "Failed to navigate to monorepo directory."
git remote add origin "$REMOTE_URL"
git push origin --all || error_exit "Failed to push all branches to remote: $REMOTE_URL."
git push origin --tags || error_exit "Failed to push all tags to remote: $REMOTE_URL."
popd > /dev/null

echo "All repositories have been successfully merged into $MONOREPO_DIR."
