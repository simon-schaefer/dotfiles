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
        echo "Error: Missing arguments. Usage: concat-videos-horizontally <directory> <output_filename> [filename_fontsize]"
        return 1
    fi

    local dir="$1"
    local output_file="$2"
    
    # Check if filename fontsize is provided
    local filename_fontsize=18
    if [ -n "$3" ]; then
        filename_fontsize="$3"
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
        local caption="${filename%.*}"
        # Add text overlay with filename
        if [ ! "$filename_fontsize" -eq 0 ]; then
            ffmpeg -i "$file" -vf "drawtext=text='$caption':x=(w-text_w)/2:y=h-50:fontcolor=white:fontsize=$filename_fontsize" -c:a copy "$tmp_dir/video_$index.mp4"
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
    for ((i = 0; i < index; i++)); do
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
        echo "Error: Missing arguments. Usage: concat-videos-vertically <directory> <output_filename> [filename_fontsize]"
        return 1
    fi

    local dir="$1"
    local output_file="$2"

    # Check if filename fontsize is provided
    local filename_fontsize=18
    if [ -n "$3" ]; then
        filename_fontsize="$3"
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
        local caption="${filename%.*}"
        if [ ! "$filename_fontsize" -eq 0 ]; then
            # Add text overlay with filename
            ffmpeg -i "$file" -vf "drawtext=text='$caption':x=(w-text_w)/2:y=50:fontcolor=white:fontsize=$filename_fontsize" -c:a copy "$tmp_dir/video_$index.mp4"
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
    for ((i = 0; i < index; i++)); do
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
        echo "Error: Missing arguments. Usage: concat-videos <directory> <rows> <columns> <output-file> [filename_fontsize]"
        return 1
    fi

    local dir="$1"
    local rows="$2"
    local cols="$3"
    local output_file="$4"
    
    local fontsize="18"
    if [ -n "$5" ]; then
        fontsize="$5"
    fi

    # Check if the provided input is a directory
    if [ ! -d "$dir" ]; then
        echo "Error: $dir is not a valid directory."
        return 1
    fi

    # Create a temporary working directory
    local tmp_dir=$(mktemp -d)
    local tmp_dir_rows=$(mktemp -d)

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
            ffmpeg -f lavfi -i color=c=black:s=256x256:r=30 -t 10 -c:v libx264 -crf 18 "${tmp_dir}/blank_${i}.mp4" &>/dev/null
        done
    fi


    # Split videos into rows
    local row_dirs=()
    local video_index=0
    for ((i=0; i<rows; i++)); do
        local row_dir="${tmp_dir_rows}/row_${i}"
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
        concat-videos-horizontally "${row_dir}" "${row_output_file}" "${fontsize}"
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
    concat-videos-vertically "${vstack_dir}" "${output_file}" 0 

    # # Clean up temporary files
    rm -rf "$tmp_dir"
    rm -rf "$tmp_dir_rows"
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
    for ((i = 0; i < index; i++)); do
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
    for ((i = 0; i < index; i++)); do
        echo "file video_${i}.mp4" >> "$concat_file"
    done

    # Run ffmpeg with the generated arguments and the concat filter
    ffmpeg -f concat -safe 0 -i "$concat_file" -c:v libx264 "${output_file}"

    # Clean up temporary files
    rm -rf "$tmp_dir"
    echo "Concatenation complete. Output saved as $output_file"
}

# Extracts frames from a video and saves as images.
# Scales the frames to a specified resolution before saving.
#
# Arguments:
# $1 - The path to the input video file.
# $2 - The path to the directory where the output images will be saved.
# $3 - Scaling factor for image dimensions.
# 
# Returns:
# - 0 on success.
# - 1 on error (invalid arguments, input file not found, or directory issues).#
extract-frames() {
    # Check if directory and output file arguments are provided   
    if [ -z "$1" ] || [ -z "$2" ]; then                               
        echo "Error: Missing arguments. Usage: extract-frames <video-file> <out-directory> [scaling-factor]"
        return 1
    fi                                                                                                                                                                       
    local input_video="$1"
    local output_dir="$2"
    local scale_factor=1
    if [ -n "$3" ]; then
        scale_factor="$3"
    fi

    # Check if the input video exists.
    if [ ! -f "$input_video" ]; then
        echo "Error: Input video file not found."
        return 1
    fi

    # Create the output directory if it doesn't exist.
    mkdir -p "$output_dir"

    # Use FFmpeg to extract frames, optionally scale, and save as images.
    ffmpeg -i "$input_video" \
       -vf "scale=iw*${scale_factor}:ih*${scale_factor}" \
       -q:v 2 \
       "${output_dir}/frame_%06d.jpg"
}

# Concatenate all given inputs to a video file. 
#
# Arguments:
# $1 - The input files.
# $2 - The output file.
# $3 - Frames per seconds as integer.
#
# Returns:
# - 0 on success.
# - 1 on error (invalid arguments, input file not found, or directory issues).#
#
# Example:
#   concatenate-frames dir/%04d.png output.mp4 10
concatenate-frames() {
    # Check if directory and output file arguments are provided
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
        echo "Error: Missing arguments. Usage: concatenate-frames <inputs> <output-file> <fps>"
        return 1
    fi

    local inputs="$1"
    local output_file="$2"
    local fps="$3"

    # Use FFmpeg to concatenate frames and save as a video.
    ffmpeg -framerate $fps \
           -i "${inputs}" \
           -c:v libx264 \
           -crf 18 \
           -pix_fmt yuv420p \
           "$output_file"
}
