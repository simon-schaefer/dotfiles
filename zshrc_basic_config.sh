# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
if [ -d "$HOME/.oh-my-zsh" ]; then
    export ZSH="$HOME/.oh-my-zsh"
    ZSH_THEME="eastwood"
    plugins=(git)
    source $ZSH/oh-my-zsh.sh
fi

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

#################################################
## FFMPEG utility functions.
#################################################

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
#   concat-videos-horizontally /path/to/videos output.mp4
concat-videos-horizontally() {
    # Check if directory and output file arguments are provided
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Error: Missing arguments. Usage: concat-videos-horizontally <directory> <output_filename>"
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

concat-videos-vertically() {
    # Check if directory and output file arguments are provided
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Error: Missing arguments. Usage: concat-videos-vertically <directory> <output_filename> [filename_overlay]"
        return 1
    fi

    local dir="$1"
    local output_file="$2"

    # Check if filename_overlay flag is provided
    local filename_overlay=0
    if [ -n "$3" ]; then
        if [ "$3" = "true" ]; then
            filename_overlay=1
        elif [ "$3" = "false" ]; then
            filename_overlay=0
        else
            echo "Error: Invalid value for filename_overlay flag. Use 'true' or 'false'."
            return 1
        fi
    fi

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
        if [ "$filename_overlay" -eq 1 ]; then
            # Add text overlay with filename
            ffmpeg -i "$file" -vf "drawtext=text='$filename':x=(w-text_w)/2:y=50:fontcolor=white:fontsize=18" -c:a copy "$tmp_dir/video_$index.mp4"
        else 
            cp "$file" "$tmp_dir/video_$index.mp4"
        fi
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

    # # Concatenate the videos side by side using ffmpeg. For whatever reason bash cannot handle quotes inside. 
    ffmpeg_args+=(
        -filter_complex "vstack=inputs=${index}"
        -c:v libx264
        "${output_file}"
    )
    ffmpeg "${ffmpeg_args[@]}"

    # Clean up temporary files
    rm -rf "$tmp_dir"

    echo "Concatenation complete. Output saved as $output_file"
}


## Concatenates multiple MP4 videos from a specified directory to a video grid.
# Adds a text overlay with the filename on each video.
# 
# Arguments:
#   $1 - The path to the directory containing the MP4 files.
#   $2 - The number of rows.
#   $3 - The number of columns.
#   $4 - The name of the output video file (e.g., output.mp4).
#
# Returns:
#   - 0 on success.
#   - 1 on error (invalid arguments, no files found, or directory issues).
#
# Example:
#   concat-videos /path/to/videos 4 5 output.mp4
concat-videos() {
    # Check if directory, rows, and columns arguments are provided
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] ; then
        echo "Error: Missing arguments. Usage: concat-videos <directory> <rows> <columns> <output-file>"
        return 1
    fi

    local dir="$1"
    local rows="$2"
    local cols="$3"
    local output_file="$4"

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
        cp "$file" "${tmp_dir}/${filename}"
        ((index++))
    done


    # Check if any files were processed
    if [ $index -eq 0 ]; then
        echo "No MP4 files found in the directory."
        return 1
    fi


    # Calculate total number of cells
    local total_cells=$((rows * cols))


    # Check if there are enough videos to fill all cells
    if [ $index -lt $total_cells ]; then
        echo "Warning: Not enough videos to fill all cells. Empty cells will be black."
        # Create blank videos for empty cells
        for ((i=index; i<total_cells; i++)); do
            ffmpeg -f lavfi -i color=c=black:s=1280x720:r=30 -t 10 -c:v libx264 -crf 18 "${tmp_dir}/blank_${i}.mp4" &>/dev/null
        done
    fi


    # Split videos into rows
    local row_dirs=()
    local video_index=0
    for ((i=0; i<rows; i++)); do
        local row_dir="${tmp_dir}/row_${i}"
        mkdir "${row_dir}"
        for ((j=0; j<cols; j++)); do
            if [ $video_index -lt $index ]; then
                local file=$(ls "${tmp_dir}" | head -n $((video_index+1)) | tail -n 1)
                cp "${tmp_dir}/${file}" "${row_dir}/"
            else
                cp "${tmp_dir}/blank_${video_index}.mp4" "${row_dir}/"
            fi
            ((video_index++))
        done
        row_dirs+=("${row_dir}")
    done


    # Concatenate videos horizontally in each row
    local hstacked_videos=()
    for row_dir in "${row_dirs[@]}"; do
        local row_output_file="${row_dir}/hstacked.mp4"
        concat-videos-horizontally "${row_dir}" "${row_output_file}"
        hstacked_videos+=("${row_output_file}")
    done


    # Create a new directory for vertically stacked videos
    local vstack_dir="${tmp_dir}/vstack"
    mkdir "${vstack_dir}"


    # Move horizontally stacked videos to the new directory
    local index=0
    for file in "${hstacked_videos[@]}"; do
        cp "${file}" "${vstack_dir}/${index}.mp4"
        ((index++))
    done

    # Concatenate videos vertically. Do not draw the filename to the video, as it is temporary.
    concat-videos-vertically "${vstack_dir}" "${output_file}" false
    #
    # # Clean up temporary files
    rm -rf "$tmp_dir"
    echo "Concatenation complete. Output saved as $output_file"
}

concat-videos-in-time() {
    # Check if directory and output file arguments are provided   
    if [ -z "$1" ] || [ -z "$2" ]; then                               
        echo "Error: Missing arguments. Usage: concat-videos-in-time <directory> <output_filename>"
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
    local max_width=0
    local max_height=0
    for file in "$dir"/*.mp4; do                   
        [ -e "$file" ] || continue  # Skip if no files found
        local filename=$(basename "$file")
        # Get video dimensions
        local width=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=s=x:p=0 "$file")
        local height=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=s=x:p=0 "$file")
        # Update maximum dimensions
        if (( width > max_width )); then
            max_width=$width
        fi
        if (( height > max_height )); then
            max_height=$height
        fi
        cp "$file" "$tmp_dir/video_$index.mp4"
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

    # Concatenate the videos in time using ffmpeg.
    ffmpeg_args+=( 
        -filter_complex "concat=n=${index}:v=1:a=1"
        -c:v libx264
        "${output_file}"
    )
    echo $ffmpeg_args

    # Create a text file listing the inputs for the concat filter
    local concat_file="${tmp_dir}/inputs.txt"
    for i in $(seq 0 $((index-1))); do
        echo "file video_${i}.mp4" >> "$concat_file"
    done

    # Run ffmpeg with the generated arguments and the concat filter
    ffmpeg -f concat -safe 0 -i "$concat_file" -c:v libx264 "${output_file}"

    # Clean up temporary files
    rm -rf "$tmp_dir"
    echo "Concatenation complete. Output saved as $output_file"
}


#################################################
## Bash utility functions.
#################################################

## Function that applies a provided function to each file
# Arguments:
#   $1 - Function to apply to each file (with two inputs, input and output file). 
#   $2 - Output directory.
#
# Returns:
#   - 0 on success.
#   - 1 on error (invalid arguments, no files found, or directory issues).
#
# Example:
#   apply_function_to_files function-name output-directory 
apply-function-to-files() {
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
    if [[ -f "$file" ]]; then
        local filename=$(basename "$file")
        $func "$file" "${output_directory}/${filename}"
    else
        echo "Skipping '$file' (not a file)"
    fi
    done
}

## FZF setup.
source <(fzf --zsh)

