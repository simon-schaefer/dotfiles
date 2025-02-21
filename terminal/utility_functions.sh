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
