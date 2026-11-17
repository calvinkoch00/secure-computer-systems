import math
import secrets
import sys

def generate_password(num_words):
    # Load the native Unix/macOS dictionary
    wordlist_path = '/usr/share/dict/words'
    
    with open(wordlist_path, 'r') as file:
        # Strip whitespace and filter to only alphabetical words to avoid punctuation
        words = [word.strip().lower() for word in file if word.strip().isalpha()]
    
    wordlist_size = len(words)
    
    # Use the secrets module for cryptographically secure random selection
    password_words = [secrets.choice(words) for _ in range(num_words)]
    password = " ".join(password_words)
    
    # Calculate entropy
    # Entropy = (Number of Words) * log2(Size of Wordlist)
    entropy = num_words * math.log2(wordlist_size)
    
    # Calculate equivalent random characters
    # [a-zA-Z0-9] = 26 + 26 + 10 = 62 possible characters
    # Required Chars = Total Entropy / log2(62)
    char_alphabet_size = 62
    equiv_chars = entropy / math.log2(char_alphabet_size)
    
    # Output matching the lab's requested format
    print(f"\n{password}")
    print(f"{num_words} RANDOM words from word list of {wordlist_size} words")
    print(f"Entropy: {entropy:.2f} bits")
    print(f"You need {equiv_chars:.2f} RANDOM characters in [a-z, A-Z, 0-9] to get the same entropy.\n")

if __name__ == "__main__":
    try:
        num = int(sys.argv[1]) if len(sys.argv) > 1 else int(input("Enter number of words: "))
        generate_password(num)
    except ValueError:
        print("Please provide a valid integer.")