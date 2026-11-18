import os
import sys
import shutil

def main():
    temp_file_path = "tocttou/temp_file.txt"
    os.makedirs(os.path.dirname(temp_file_path), exist_ok=True)
    
    while True:
        try:
            print(f"\n[*] Opening '{temp_file_path}' for writing...")
            fd = open(temp_file_path, "w")
            
            input("[!] Program paused. Perform TOCTTOU modifications now, then press Enter...")
            
            fd.write("Data written during the TOCTTOU test.\n")
            fd.close()
            print("[+] File closed successfully. Reading content:")
            
            print("---")
            try:
                with open(temp_file_path, "r") as f:
                    print(f.read().rstrip('\n'))
            except FileNotFoundError:
                print("File no longer exists (deleted during pause).")
            print("---")
            
        except Exception as e:
            print(f"[-] Error occurred: {e}", file=sys.stderr)
        
        if input("\nDo you want to run the test again? (y/n) [y]: ").lower() not in ['y', 'yes', '']:
            break

    if input("Do you want to clean up the temporary folder? (y/n) [y]: ").lower() in ['y', 'yes', '']:
        dir_path = os.path.dirname(temp_file_path)
        if os.path.exists(dir_path):
            shutil.rmtree(dir_path)
            print(f"[+] Directory {dir_path} and its contents removed.")

if __name__ == "__main__":
    main()