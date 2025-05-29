import os
import shutil

def convert_gml_to_txt_flat(source_dir, output_dir):
    """
    Searches a source directory for .gml files, converts them to .txt,
    and copies them to a single output directory (flat structure).
    Handles filename collisions by appending a number.
    """
    source_dir = os.path.abspath(source_dir)  # Normalize path
    output_dir = os.path.abspath(output_dir)  # Normalize path

    if not os.path.isdir(source_dir):
        print(f"Error: Source directory '{source_dir}' not found.")
        return

    if not os.path.exists(output_dir):
        try:
            os.makedirs(output_dir)
            print(f"Created output directory: '{output_dir}'")
        except OSError as e:
            print(f"Error: Could not create output directory '{output_dir}': {e}")
            return
    elif not os.path.isdir(output_dir):
        print(f"Error: Output path '{output_dir}' exists but is not a directory.")
        return

    print(f"\nScanning '{source_dir}' for .gml files...")
    converted_count = 0
    found_count = 0

    for root, _, files in os.walk(source_dir):
        for filename in files:
            if filename.lower().endswith(".gml"):
                found_count += 1
                source_gml_path = os.path.join(root, filename)

                # Create the new .txt filename
                base_filename_no_ext, _ = os.path.splitext(filename)
                output_txt_filename_base = base_filename_no_ext + ".txt"
                output_txt_path = os.path.join(output_dir, output_txt_filename_base)

                # Handle potential filename collisions in the flat output directory
                counter = 1
                temp_output_txt_filename = output_txt_filename_base
                while os.path.exists(output_txt_path):
                    temp_output_txt_filename = f"{base_filename_no_ext}_{counter}.txt"
                    output_txt_path = os.path.join(output_dir, temp_output_txt_filename)
                    counter += 1
                
                if temp_output_txt_filename != output_txt_filename_base:
                    print(f"  Note: Filename collision. Renaming to '{temp_output_txt_filename}'")

                try:
                    # Copy the file content
                    shutil.copy2(source_gml_path, output_txt_path) # copy2 preserves metadata
                    print(f"  Copied and renamed: '{source_gml_path}' -> '{output_txt_path}'")
                    converted_count += 1
                except Exception as e:
                    print(f"  Error copying '{source_gml_path}' to '{output_txt_path}': {e}")

    print(f"\n--- Process Complete ---")
    print(f"Found {found_count} .gml files.")
    print(f"Successfully converted and copied {converted_count} files to '{output_dir}'.")

if __name__ == "__main__":
    print("--- GML to TXT File Converter (Flat Output) ---")
    source_folder = input("Enter the path to the main folder (source): ").strip()
    output_folder = input("Enter the path to the output directory (destination): ").strip()

    if source_folder and output_folder:
        if os.path.abspath(source_folder) == os.path.abspath(output_folder):
            print("Error: Source and output directories cannot be the same if flattening, as this could lead to overwriting original .gml files if they were also named .txt somehow.")
        else:
            convert_gml_to_txt_flat(source_folder, output_folder)
    else:
        print("Error: Both source and output paths are required.")