import sys
import os
import subprocess

# Small helper that ensures PyPDF2 is installed
def ensure_pkg(pkg):
    try:
        __import__(pkg)
    except Exception:
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', pkg])

ensure_pkg('PyPDF2')
from PyPDF2 import PdfReader

def count_chars_in_pdf(path):
    if not os.path.exists(path):
        print(f"ERROR: file not found: {path}")
        return 2
    try:
        reader = PdfReader(path)
        text_parts = []
        for page in reader.pages:
            try:
                t = page.extract_text()
            except Exception:
                t = None
            if t:
                text_parts.append(t)
        all_text = "".join(text_parts)
        # Print a machine-parseable line and a friendly line
        print(f"CHAR_COUNT:{len(all_text)}")
        print(f"Extracted {len(all_text)} characters from '{path}'.")
        return 0
    except Exception as e:
        print("ERROR: exception while reading PDF:", e)
        return 3

if __name__ == '__main__':
    pdf_path = sys.argv[1] if len(sys.argv) > 1 else 'out/main.pdf'
    rc = count_chars_in_pdf(pdf_path)
    sys.exit(rc)

