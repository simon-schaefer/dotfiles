# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="eastwood"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# Conda setup.
launch-conda() {
    __conda_setup="$("$HOME/.miniconda/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "$HOME/.miniconda/etc/profile.d/conda.sh" ]; then
            . "$HOME/.miniconda/etc/profile.d/conda.sh"
        else
            export PATH="$HOME/.miniconda/bin:$PATH"
        fi
    fi
    unset __conda_setup
}

# FFMPEG utility function.

## Concatenates multiple MP4 videos from a specified directory side by side into a single output video. 
# Adds a text overlay with the filename on each video.
# 
# Arguments:
#   $1 - The path to the directory containing the MP4 files.
#   $2 - The name of the output video file (e.g., output.mp4).
#
# Returns:
#   - 0 on success.
#   - 1 on error (invalid arguments, no files found, or directory issues).
#
# Example:
#   concat_videos_side_by_side /path/to/videos output.mp4
concat-videos-side-by-side() {


    # Check if directory and output file arguments are provided
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Error: Missing arguments. Usage: concat_videos_side_by_side <directory> <output_filename>"
        return 1
    fi

    local dir="$1"
    local output_file="$2"

    # Check if the provided input is a directory
    if [ ! -d "$dir" ]; then
        echo "Error: $dir is not a valid directory."
        return 1
    fi

    # Create a temporary working directory
    local tmp_dir=$(mktemp -d)

    # Process each MP4 file
    local index=0
    for file in "$dir"/*.mp4; do
        [ -e "$file" ] || continue  # Skip if no files found
        local filename=$(basename "$file")
        # Add text overlay with filename
        ffmpeg -i "$file" -vf "drawtext=text='$filename':x=(w-text_w)/2:y=h-50:fontcolor=white:fontsize=18" -c:a copy "$tmp_dir/video_$index.mp4"
        ((index++))
    done

    # Check if any files were processed
    if [ $index -eq 0 ]; then
        echo "No MP4 files found in the directory."
        return 1
    fi

    # Generate a list of inputs for ffmpeg
    ffmpeg_args=()
    for i in $(seq 0 $((index-1))); do
        ffmpeg_args+=(-i "${tmp_dir}/video_${i}.mp4")
    done

    # Concatenate the videos side by side using ffmpeg. For whatever reason bash cannot handle quotes inside. 
    ffmpeg_args+=(
        -filter_complex "hstack=inputs=${index}"
        -c:v libx264
        "${output_file}"
    )
    ffmpeg "${ffmpeg_args[@]}"

    # Clean up temporary files
    rm -rf "$tmp_dir"

    echo "Concatenation complete. Output saved as $output_file"
}

# FZF setup.
source <(fzf --zsh)

