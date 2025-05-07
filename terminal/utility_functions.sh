## Function that applies a provided function to each given element 
# Arguments:
#   $1 - Function to apply to each file (with two inputs, input and output file). 
#   $2 - Output directory.
#
# Returns:
#   - 0 on success.
#   - 1 on error (invalid arguments, no files found, or directory issues).
#
# Example:
#   apply-function-to-elements function-name output-directory *.mp4
apply-function-to-elements() {
    # Check if directory and output file arguments are provided
    if [ -z "$1" ] || [ -z "$2" ]; then 
        echo "Error: Missing arguments. Usage: apply_function_to_files <function> <output_directory>"
        return 1
    fi
    local func="$1"  
    local output_directory="$2"

     # Shift the positional arguments to skip the function name
    shift; shift

    mkdir -p "$output_directory"
    for file in "$@"; do
        local filename=$(basename "$file")
        $func "$file" "${output_directory}/${filename}"
    done
}


## Merge several directories to a single output directory by prefixing the directory name.
# Arguments:
#   $1...N - Input directories.
#   $N - Output directory.
#
# Returns:
#   - 0 on success.
#   - 1 on error (invalid arguments, no files found, or directory issues).
#
# Example:
#   merge-directories dir1/ dir2/ output-dir/
merge-directories() {
    local output_dir="${@: -1}"
    local input_dirs=("${@:1:${#@}-1}")

    if [ ! -d "$output_dir" ]; then
        mkdir -p "$output_dir"
    fi

    for dir in "${input_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            echo "error: input directory '$dir' does not exist."
            continue
        fi

        for file in "$dir"/*; do
            filename=$(basename "$file")
            newfilename="${dir%/}-${filename}"
            cp "$file" "${output_dir}/${newfilename##*/}"
        done
    done
}

## Flatten directory by replacing all "/" with "_" and copy to output directory.
# Arguments:
#   $1 - Input directory.
#   $2 - Output directory.
#
# Returns:
#   - 0 on success.
#   - 1 on error (invalid arguments, no files found, or directory issues).
#
# Example:
#   flatten-directory dir/ output-dir/
flatten-directory() {
    local input_dir="$1"
    local output_dir="$2"

    if [ ! -d "$input_dir" ]; then
        echo "Error: Input directory '$input_dir' does not exist."
        return 1
    fi

    mkdir -p "$output_dir"

    while IFS= read -r -d '' file; do
        relative_path="${file#$input_dir/}"
        new_filename="${relative_path//\//_}"
        cp -p "$file" "$output_dir/$new_filename"
    done < <(find "$input_dir" -type f -print0)
}

rename-sequential() {
  local dir="${1:-.}"         # Directory (default: current)
  local ext="${2:-png}"       # Extension (default: png)
  
  # Check if directory exists
  if [ ! -d "$dir" ]; then
    echo "Error: Directory '$dir' does not exist"
    return 1
  fi
  
  # Create array of files (excluding hidden files)
  local files=()
  while IFS= read -r file; do
    files+=("$file")
  done < <(find "$dir" -maxdepth 1 -type f -not -path "*/\.*" | sort)
  
  local total=${#files[@]}
  if [ "$total" -eq 0 ]; then
    echo "No files found in directory '$dir'"
    return 0
  fi

  echo "Renaming $total files..."
  for i in $(seq 0 $total); do
    local new_name=$(printf "%04d.%s" $i "$ext")
    local old_name=${files[$i]}
    if [ "$old_name" = "$dir$new_name" ]; then 
      continue 
    fi
    mv "$old_name" "$dir/$new_name"
  done
}
