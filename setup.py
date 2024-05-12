import shutil
import os

def move_and_grant_permission(source_file, destination_dir):
    try:
        # Check if the source file exists
        if not os.path.exists(source_file):
            print(f"Error: {source_file} does not exist.")
            return

        # Check if the destination directory exists, create it if it doesn't
        if not os.path.exists(destination_dir):
            os.makedirs(destination_dir)

        # Move the file to the destination directory
        shutil.move(source_file, destination_dir)

        # Set execute permissions for the file
        os.chmod(os.path.join(destination_dir, os.path.basename(source_file)), 0o755)

        print(f"{source_file} moved to {destination_dir} and given execute permission.")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    source_file = "whois"  # Assuming the file is in the current directory
    destination_dir = "/usr/local/bin"

    move_and_grant_permission(source_file, destination_dir)
